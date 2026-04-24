#if os(iOS)
import SwiftUI

struct WandKitView: View {
    let response: EventResponse

    @State private var isVisible = false
    @State private var isDismissing = false
    @State private var isShowingThankYou = false
    @State private var currentBlockIndex = 0
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

        return currentBlock?.id ?? "wandkit-empty"
    }

    var currentBlock: EventResponse.Block? {
        guard response.form.blocks.indices.contains(currentBlockIndex) else {
            return nil
        }

        return response.form.blocks[currentBlockIndex]
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

                if let block = currentBlock {
                    blockView(for: block)
                        .id(block.id)
                }
            }
        }
    }

    @ViewBuilder
    func blockView(for block: EventResponse.Block) -> some View {
        switch block.type {
        case .stars:
            WandKitStarsBlockView(block: block) { value in
                selectedStars[block.id] = value
                advance(from: block)
            }
        case .thumbs:
            WandKitThumbsBlockView(block: block) { isPositive in
                selectedThumbs[block.id] = isPositive
                advance(from: block)
            }
        case .multiChoice:
            WandKitMultiChoiceBlockView(
                block: block,
                selection: selectionBinding(for: block),
                onSkip: {
                    selectedOptions[block.id] = []
                    advance(from: block)
                },
                onConfirm: {
                    advance(from: block)
                }
            )
        case .text:
            WandKitTextBlockView(
                block: block,
                text: textBinding(for: block),
                onSkip: {
                    textValues[block.id] = ""
                    advance(from: block)
                },
                onConfirm: {
                    advance(from: block)
                }
            )
        }
    }

    func advance(from block: EventResponse.Block) {
        if currentBlockIndex < response.form.blocks.count - 1 {
            WandKitHaptics.stepChange()

            withAnimation(.snappy(duration: animationDuration)) {
                currentBlockIndex += 1
            }
        } else {
            WandKitLogger.debug("Completed form for eventId=\(response.eventId), lastBlockId=\(block.id)")
            showThankYouThenDismiss()
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
        WandKitLogger.debug("Dismiss requested")
        isDismissing = true

        withAnimation(.snappy(duration: animationDuration)) {
            isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            WandKitWindowPresenter.dismiss()
        }
    }

    func textBinding(for block: EventResponse.Block) -> Binding<String> {
        Binding(
            get: { textValues[block.id] ?? "" },
            set: { newValue in
                if let maxLength = block.maxLength {
                    textValues[block.id] = String(newValue.prefix(maxLength))
                } else {
                    textValues[block.id] = newValue
                }
            }
        )
    }

    func selectionBinding(for block: EventResponse.Block) -> Binding<Set<String>> {
        Binding(
            get: { selectedOptions[block.id] ?? [] },
            set: { newValue in
                if block.allowMultiple == true {
                    selectedOptions[block.id] = newValue
                } else {
                    if let firstValue = newValue.first {
                        selectedOptions[block.id] = [firstValue]
                    } else {
                        selectedOptions[block.id] = []
                    }
                }
            }
        )
    }
}
#endif
