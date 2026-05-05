#if os(iOS)
import SwiftUI

struct WandKitMultiChoiceBlockView: View {
    let page: EventResponse.Page
    @Binding var selection: Set<String>
    let onSkip: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            WandKitBlockLabelView(page: page)

            VStack(alignment: .center, spacing: 8) {
                ForEach(page.options ?? [], id: \.id) { option in
                    Button {
                        WandKitHaptics.buttonTap()
                        toggle(optionId: option.id)
                    } label: {
                        HStack {
                            Image(systemName: selection.contains(option.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(Color(uiColor: .tintColor))
                            Text(option.label)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 12) {
                actionButton(title: "Skip", isPrimary: false, action: onSkip)
                actionButton(title: page.nextButtonLabel ?? "Confirm", isPrimary: true, action: onConfirm)
            }
        }
    }
}

private extension WandKitMultiChoiceBlockView {
    func toggle(optionId: String) {
        if page.allowMultiple == true {
            if selection.contains(optionId) {
                selection.remove(optionId)
            } else {
                selection.insert(optionId)
            }
        } else {
            selection = [optionId]
        }
    }

    func actionButton(title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            WandKitHaptics.buttonTap()
            action()
        }) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(
                    isPrimary
                        ? Color(uiColor: .systemBackground)
                        : Color(uiColor: .tintColor)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isPrimary
                        ? Color(uiColor: .tintColor)
                        : Color(uiColor: .tertiarySystemFill)
                )
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
#endif
