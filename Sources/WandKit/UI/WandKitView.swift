#if os(iOS)
import SwiftUI

struct WandKitView: View {
    let response: EventResponse
    let onSubmit: @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void
    let onDismiss: @Sendable () async -> Void

    @State private var isVisible = false
    @State private var isDismissing = false
    @State private var didSubmit = false
    @State private var didDismiss = false
    @State private var currentPageId: String?
    @State private var visitedPageIds: Set<String> = []
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
            showPoweredByLabel: !response.form.isPro,
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
        return currentPage?.id ?? "wandkit-empty"
    }

    var currentPage: EventResponse.Page? {
        let resolvedPageId = currentPageId ?? response.form.pages.first?.id
        guard let resolvedPageId else {
            return response.form.pages.first
        }

        return response.form.pages.first { $0.id == resolvedPageId }
    }

    @ViewBuilder
    var contentView: some View {
        ZStack {
            if let page = currentPage {
                pageView(for: page)
                    .id(page.id)
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
        case .end:
            WandKitEndBlockView(
                page: page,
                hasNextPage: resolveNextPageId(from: page) != nil,
                onContinue: {
                    advance(from: page)
                },
                onFinished: {
                    completeFlowIfNeeded()
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
        visitedPageIds.insert(page.id)

        if let nextPageId = resolveNextPageId(from: page),
           response.form.pages.contains(where: { $0.id == nextPageId }) {
            WandKitHaptics.stepChange()

            withAnimation(.snappy(duration: animationDuration)) {
                currentPageId = nextPageId
            }
        } else {
            completeFlowIfNeeded()
        }
    }

    func completeFlowIfNeeded() {
        submitAnswersOnce()
        showThankYouThenDismiss()
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
            guard visitedPageIds.contains(page.id), page.type != .end else {
                return nil
            }

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
            case .end:
                return nil
            }
        }
    }

    func showThankYouThenDismiss() {
        autoDismissTask?.cancel()
        WandKitHaptics.success()

        autoDismissTask = Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)

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

    func resolveNextPageId(from page: EventResponse.Page) -> String? {
        for rule in page.next {
            guard conditionMatches(rule.condition, on: page) else {
                continue
            }

            return rule.pageId
        }

        return nil
    }

    func conditionMatches(_ condition: String?, on page: EventResponse.Page) -> Bool {
        guard let condition, !condition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }

        switch page.type {
        case .thumbs:
            switch condition {
            case "thumb.up":
                return selectedThumbs[page.id] == true
            case "thumb.down":
                return selectedThumbs[page.id] == false
            default:
                return false
            }
        case .stars:
            guard condition.hasPrefix("star."),
                  let value = Int(condition.replacingOccurrences(of: "star.", with: "")) else {
                return false
            }

            return selectedStars[page.id] == value
        case .multiChoice:
            guard condition.hasPrefix("option.") else {
                return false
            }

            let optionId = String(condition.dropFirst("option.".count))
            return selectedOptions[page.id, default: []].contains(optionId)
        case .text, .end:
            return false
        }
    }
}
#endif
