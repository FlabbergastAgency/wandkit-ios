#if os(iOS)
import SwiftUI

struct WandKitAnimatedContentContainer<Content: View, ContentID: Hashable>: View {
    let contentID: ContentID
    let isVisible: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(uiColor: .systemBackground)
                    .opacity(isVisible ? 0.45 : 0)
                    .ignoresSafeArea()
                    .onTapGesture(perform: onDismiss)

                VStack {
                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Spacer()

                            Button(action: onDismiss) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(uiColor: .label))
                                    .frame(width: 36, height: 36)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        ZStack {
                            content()
                                .id(contentID)
                                .measureHeight { measuredHeight in
                                    guard measuredHeight > 0 else {
                                        return
                                    }

                                    contentHeight = measuredHeight
                                }
                                .blurTransitionIfAvailable()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: contentHeight, alignment: .top)
                        .clipped()
                    }
                    .padding(20)
                    .frame(
                        maxWidth: min(420, max(proxy.size.width - 32, 0)),
                        alignment: .leading
                    )
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.16), radius: 24, y: 12)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.92)
            }
        }
        .animation(.snappy(duration: 0.34), value: contentID)
        .animation(.snappy(duration: 0.34), value: contentHeight)
    }
}

private struct WandKitMeasuredHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public extension View {
    @ViewBuilder
    func blurTransitionIfAvailable() -> some View {
        if #available(iOS 17, *) {
            self.transition(.blurReplace)
        } else {
            self.transition(.opacity)
        }
    }
}

private extension View {
    func measureHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: WandKitMeasuredHeightPreferenceKey.self, value: proxy.size.height)
            }
        }
        .onPreferenceChange(WandKitMeasuredHeightPreferenceKey.self, perform: onChange)
    }
}
#endif
