#if os(iOS)
import SwiftUI

struct WandKitBlockLabelView: View {
    let block: EventResponse.Block

    var body: some View {
        HStack(spacing: 4) {
            Text(block.label)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            if block.required {
                Text("*")
                    .foregroundColor(Color(uiColor: .systemRed))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
#endif
