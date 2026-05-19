#if os(iOS)
import SwiftUI

struct WandKitEndBlockView: View {
    let page: EventResponse.Page
    let hasNextPage: Bool
    let onContinue: () -> Void
    let onFinished: () -> Void
    @Environment(\.wandKitTheme) private var theme

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            WandKitBlockLabelView(page: page)
                .padding(.vertical, 20)

            if hasNextPage {
                Button(
                    action: {
                        WandKitHaptics.buttonTap()
                        onContinue()
                    },
                    label: {
                        Text(page.nextButtonLabel ?? "Continue")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(uiColor: .systemBackground))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.accentColor)
                            .cornerRadius(theme.buttonCornerRadius)
                    }
                )
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            guard !hasNextPage else {
                return
            }

            onFinished()
        }
    }
}
#endif
