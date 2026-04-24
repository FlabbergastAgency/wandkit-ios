#if os(iOS)
import SwiftUI

struct ThankYouView: View {
    @State var progress: CGFloat = 0.05

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            TimeProgressView(progress: progress)
                .frame(width: 80, height: 6)

            VStack(spacing: 12) {
                Text("🙏")
                    .font(.system(size: 56))

                Text("Thank you!")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.8).delay(0.2)) {
                progress = 1
            }
        }
    }
}
#endif
