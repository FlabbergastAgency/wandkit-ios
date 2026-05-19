#if os(iOS)
import SwiftUI

struct WandKitThumbsBlockView: View {
    let page: EventResponse.Page
    let onSelect: (Bool) -> Void

    @State private var selectedValue: Bool?
    @State private var isAdvancing = false
    @Environment(\.wandKitTheme) private var theme

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
                        : theme.accentColor
                )
                .frame(width: 52, height: 52)
                .background(
                    isSelected
                        ? theme.accentColor
                        : Color(uiColor: .tertiarySystemFill)
                )
                .cornerRadius(12)
        }
        .buttonStyle(ThumbButtonStyle())
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

public struct ThumbButtonStyle: ButtonStyle {
    public init() {}
    @State var scale: CGFloat = 1
    @State var brightness: CGFloat = 0

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(scale)
            .brightness(brightness)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    withAnimation(.snappy(duration: 0.1)) {
                        scale = 1.12
                        brightness = 0.2
                    }
                } else {
                    withAnimation(.bouncy) {
                        scale = 1
                        brightness = 0
                    }
                }
            }
    }
}
#endif
