#if os(iOS)
import SwiftUI

struct WandKitStarsBlockView: View {
    let page: EventResponse.Page
    let onSelect: (Int) -> Void

    @State private var selectedValue = 0
    @State private var isAdvancing = false

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
                        ? Color(uiColor: .systemYellow)
                        : Color(uiColor: .secondaryLabel)
                )
                .frame(width: 56, height: 56)
                .background(
                    isSelected
                        ? Color(uiColor: .systemYellow).opacity(0.16)
                        : Color(uiColor: .secondarySystemBackground)
                )
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
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
#endif
