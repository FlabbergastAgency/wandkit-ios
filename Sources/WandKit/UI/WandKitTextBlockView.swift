#if os(iOS)
import SwiftUI

struct WandKitTextBlockView: View {
    let page: EventResponse.Page
    @Binding var text: String
    let onSkip: () -> Void
    let onConfirm: () -> Void
    @Environment(\.wandKitTheme) private var theme
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            WandKitBlockLabelView(page: page)
            
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
                
                if text.isEmpty, let placeholder = page.placeholder {
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
                actionButton(title: page.nextButtonLabel ?? "Confirm", isPrimary: true, action: onConfirm)
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
                ZStack {
                    if isPrimary {
                        Text(title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(uiColor: .label))
                            .colorScheme(.dark)
                    } else {
                        Text(title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(uiColor: .label))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isPrimary
                    ? theme.accentColor
                    : Color(uiColor: .tertiarySystemFill)
                )
                .cornerRadius(theme.buttonCornerRadius)
            }
        )
        .buttonStyle(.plain)
    }
}
#endif
