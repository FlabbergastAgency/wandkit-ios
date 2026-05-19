#if os(iOS)
import SwiftUI

struct WandKitAnimatedContentContainer<Content: View, ContentID: Hashable>: View {
    let contentID: ContentID
    let isVisible: Bool
    let showPoweredByLabel: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var contentHeight: CGFloat?
    @Environment(\.wandKitTheme) private var theme

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .opacity(isVisible ? 0.45 : 0)
                    .ignoresSafeArea()
                    .onTapGesture(perform: onDismiss)

                VStack(spacing: 10) {
                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Spacer()

                            Button(action: onDismiss) {
                                CloseButtonView()
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
                        .frame(maxWidth: .infinity)
                        .frame(height: contentHeight, alignment: .top)
                        .padding(.bottom, 16)

                        if showPoweredByLabel {
                            Text("Powered by WandKit")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(12)
                    .frame(
                        maxWidth: min(420, max(proxy.size.width - 32, 0)),
                        alignment: .leading
                    )
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: theme.modalCornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.modalCornerRadius, style: .continuous)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(Color(uiColor: .label))
                            .opacity(0.1)
                    }
                    .shadow(color: Color.black.opacity(0.16), radius: 24, y: 12)
                    Spacer(minLength: 0)
                }
                .padding(12)
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.92)
                .offset(y: isVisible ? 0 : 24)
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
