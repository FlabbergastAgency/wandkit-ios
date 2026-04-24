#if os(iOS)
import SwiftUI

public struct TimeProgressView: View {
    private let progress: Double
    private let height: CGFloat
    private let backgroundColor: Color
    private let foregroundColor: Color

    public init(
        progress: Double,
        height: CGFloat = 6,
        backgroundColor: Color = Color(uiColor: .secondaryLabel).opacity(0.2),
        foregroundColor: Color = Color(uiColor: .secondaryLabel)
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    private var cornerRadius: CGFloat {
        height / 2
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(foregroundColor)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}
#endif
