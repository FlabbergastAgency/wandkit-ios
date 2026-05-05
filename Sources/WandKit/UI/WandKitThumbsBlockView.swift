#if os(iOS)
import SwiftUI

struct WandKitThumbsBlockView: View {
    let page: EventResponse.Page
    let onSelect: (Bool) -> Void

    @State private var selectedValue: Bool?
    @State private var isAdvancing = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            WandKitBlockLabelView(page: page)

            HStack(spacing: 12) {
                thumbButton(isUpvote: true)
                thumbButton(isUpvote: false)
            }
        }
    }
}

private extension WandKitThumbsBlockView {
    func thumbButton(isUpvote: Bool) -> some View {
        let isSelected = selectedValue == isUpvote

        return Button {
            handleSelection(isUpvote)
        } label: {
            Image(systemName: isUpvote ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                .font(.title3)
                .foregroundColor(
                    isSelected
                        ? Color(uiColor: .systemBackground)
                        : Color(uiColor: .tintColor)
                )
                .frame(width: 52, height: 52)
                .background(
                    isSelected
                        ? Color(uiColor: .tintColor)
                        : Color(uiColor: .tertiarySystemFill)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(isAdvancing)
    }

    func handleSelection(_ value: Bool) {
        guard !isAdvancing else {
            return
        }

        WandKitHaptics.buttonTap()
        selectedValue = value
        isAdvancing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onSelect(value)
        }
    }
}
#endif
