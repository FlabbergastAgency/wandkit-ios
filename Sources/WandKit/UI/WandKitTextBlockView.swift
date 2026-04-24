#if os(iOS)
import SwiftUI

struct WandKitTextBlockView: View {
    let block: EventResponse.Block
    @Binding var text: String
    let onSkip: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            WandKitBlockLabelView(block: block)
            
            ZStack(alignment: .topLeading) {
                if #available(iOS 16.0, *) {
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120, maxHeight: 240)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                } else {
                    TextEditor(text: $text)
                        .frame(minHeight: 120, maxHeight: 240)
                        .padding(8)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                if text.isEmpty, let placeholder = block.placeholder {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 12) {
                actionButton(title: "Skip", isPrimary: false, action: onSkip)
                actionButton(title: "Confirm", isPrimary: true, action: onConfirm)
            }
        }
    }
}

private extension WandKitTextBlockView {
    func actionButton(title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(
            action: {
                WandKitHaptics.buttonTap()
                UIApplication.shared.sendAction(
                    #selector(UIApplication.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
                action()
            },
            label: {
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
        )
        .buttonStyle(.plain)
    }
}
#endif
