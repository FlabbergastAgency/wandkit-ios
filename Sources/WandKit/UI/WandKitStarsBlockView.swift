#if os(iOS)
import SwiftUI

struct WandKitStarsBlockView: View {
    let page: EventResponse.Page
    let onSelect: (Int) -> Void

    @State private var selectedValue = 0
    @State private var isAdvancing = false
    @Environment(\.wandKitTheme) private var theme

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            WandKitBlockLabelView(page: page)

            HStack(spacing: 12) {
                ForEach(1 ... 5, id: \.self) { value in
                    starButton(value: value)
                }
            }
        }
        .padding(.bottom, 12)
    }
}

private extension WandKitStarsBlockView {
    func starButton(value: Int) -> some View {
        let isSelected = value <= selectedValue

        return Button {
            handleSelection(value)
        } label: {
            Image(systemName: "star.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(
                    isSelected
                        ? theme.starSelectedColor
                        : theme.starUnselectedColor
                )
                .frame(width: 56, height: 56)
        }
        .buttonStyle(StarButtonStyle())
        .disabled(isAdvancing)
    }

    func handleSelection(_ value: Int) {
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

public struct StarButtonStyle: ButtonStyle {
    public init() {}
    @State var scale: CGFloat = 1

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(scale)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    withAnimation(.snappy(duration: 0.1)) {
                        scale = 1.15
                    }
                } else {
                    withAnimation(.bouncy) {
                        scale = 1
                    }
                }
            }
    }
}

#endif
