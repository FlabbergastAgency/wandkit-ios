#if os(iOS)
import SwiftUI

struct WandKitView: View {
    let response: EventResponse
    let onSubmit: @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void
    let onDismiss: @Sendable () async -> Void

    @State private var isVisible = false
    @State private var isDismissing = false
    @State private var isShowingThankYou = false
    @State private var didSubmit = false
    @State private var didDismiss = false
    @State private var currentPageIndex = 0
    @State private var selectedStars: [String: Int] = [:]
    @State private var selectedThumbs: [String: Bool] = [:]
    @State private var selectedOptions: [String: Set<String>] = [:]
    @State private var textValues: [String: String] = [:]
    @State private var autoDismissTask: Task<Void, Never>?

    private let animationDuration = 0.25

    var body: some View {
        WandKitAnimatedContentContainer(
            contentID: contentID,
            isVisible: isVisible,
            onDismiss: dismissAnimated
        ) {
            contentView
        }
        .onAppear {
            guard !isVisible else {
                return
            }

            withAnimation(.snappy(duration: animationDuration)) {
                isVisible = true
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }
}

private extension WandKitView {
    var contentID: String {
        if isShowingThankYou {
            return "wandkit-thank-you"
        }

        return currentPage?.id ?? "wandkit-empty"
    }

    var currentPage: EventResponse.Page? {
        guard response.form.pages.indices.contains(currentPageIndex) else {
            return nil
        }

        return response.form.pages[currentPageIndex]
    }

    @ViewBuilder
    var contentView: some View {
        if isShowingThankYou {
            ThankYouView()
        } else {
            VStack(alignment: .center, spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text(response.form.title)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    if !response.form.description.isEmpty {
                        Text(response.form.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }

                if let page = currentPage {
                    pageView(for: page)
                        .id(page.id)
                }
            }
        }
    }

    @ViewBuilder
    func pageView(for page: EventResponse.Page) -> some View {
        VStack(alignment: .center, spacing: 16) {
            pageImage(for: page)

            questionView(for: page)
        }
    }

    @ViewBuilder
    func questionView(for page: EventResponse.Page) -> some View {
        switch page.type {
        case .stars:
            WandKitStarsBlockView(page: page) { value in
                selectedStars[page.id] = value
                advance(from: page)
            }
        case .thumbs:
            WandKitThumbsBlockView(page: page) { isPositive in
                selectedThumbs[page.id] = isPositive
                advance(from: page)
            }
        case .multiChoice:
            WandKitMultiChoiceBlockView(
                page: page,
                selection: selectionBinding(for: page),
                onSkip: {
                    selectedOptions[page.id] = []
                    advance(from: page)
                },
                onConfirm: {
                    advance(from: page)
                }
            )
        case .text:
            WandKitTextBlockView(
                page: page,
                text: textBinding(for: page),
                onSkip: {
                    textValues[page.id] = ""
                    advance(from: page)
                },
                onConfirm: {
                    advance(from: page)
                }
            )
        }
    }

    @ViewBuilder
    func pageImage(for page: EventResponse.Page) -> some View {
        if let imageUrl = page.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(maxHeight: 160)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    func advance(from page: EventResponse.Page) {
        if currentPageIndex < response.form.pages.count - 1 {
            WandKitHaptics.stepChange()

            withAnimation(.snappy(duration: animationDuration)) {
                currentPageIndex += 1
            }
        } else {
            WandKitLogger.debug("Completed form for eventId=\(response.eventId), lastPageId=\(page.id)")
            submitAnswersOnce()
            showThankYouThenDismiss()
        }
    }

    func submitAnswersOnce() {
        guard !didSubmit else {
            return
        }

        didSubmit = true
        let answers = formAnswers()
        Task {
            await onSubmit(answers)
        }
    }

    func formAnswers() -> [SubmitFormResponseRequest.Answer] {
        response.form.pages.compactMap { page in
            switch page.type {
            case .stars:
                guard let value = selectedStars[page.id] else {
                    return nil
                }

                return .init(
                    pageId: page.id,
                    thumb: nil,
                    stars: value,
                    selectedOptionIds: nil,
                    text: nil
                )
            case .thumbs:
                guard let value = selectedThumbs[page.id] else {
                    return nil
                }

                return .init(
                    pageId: page.id,
                    thumb: value ? .up : .down,
                    stars: nil,
                    selectedOptionIds: nil,
                    text: nil
                )
            case .multiChoice:
                return .init(
                    pageId: page.id,
                    thumb: nil,
                    stars: nil,
                    selectedOptionIds: (selectedOptions[page.id] ?? []).sorted(),
                    text: nil
                )
            case .text:
                return .init(
                    pageId: page.id,
                    thumb: nil,
                    stars: nil,
                    selectedOptionIds: nil,
                    text: textValues[page.id] ?? ""
                )
            }
        }
    }

    func showThankYouThenDismiss() {
        autoDismissTask?.cancel()
        WandKitHaptics.success()

        withAnimation(.snappy(duration: animationDuration)) {
            isShowingThankYou = true
        }

        autoDismissTask = Task {
            try? await Task.sleep(nanoseconds: 1_300_000_000)

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                dismissAnimated()
            }
        }
    }

    func dismissAnimated() {
        guard !isDismissing else {
            return
        }

        autoDismissTask?.cancel()
        submitDismissalIfNeeded()
        WandKitLogger.debug("Dismiss requested")
        isDismissing = true

        withAnimation(.snappy(duration: animationDuration)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            WandKitWindowPresenter.dismiss()
        }
    }

    func submitDismissalIfNeeded() {
        guard !didDismiss, !didSubmit else {
            return
        }

        didDismiss = true
        Task {
            await onDismiss()
        }
    }

    func textBinding(for page: EventResponse.Page) -> Binding<String> {
        Binding(
            get: { textValues[page.id] ?? "" },
            set: { newValue in
                if let maxLength = page.maxLength {
                    textValues[page.id] = String(newValue.prefix(maxLength))
                } else {
                    textValues[page.id] = newValue
                }
            }
        )
    }

    func selectionBinding(for page: EventResponse.Page) -> Binding<Set<String>> {
        Binding(
            get: { selectedOptions[page.id] ?? [] },
            set: { newValue in
                if page.allowMultiple == true {
                    selectedOptions[page.id] = newValue
                } else {
                    if let firstValue = newValue.first {
                        selectedOptions[page.id] = [firstValue]
                    } else {
                        selectedOptions[page.id] = []
                    }
                }
            }
        )
    }
}
#endif
