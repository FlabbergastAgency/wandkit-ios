#if os(iOS)
import SwiftUI

struct WandKitBlockLabelView: View {
    let page: EventResponse.Page

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 4) {
                Text(page.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                if page.required {
                    Text("*")
                        .foregroundColor(Color(uiColor: .systemRed))
                        .multilineTextAlignment(.center)
                }
            }

            if let subtitle = page.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
#endif
