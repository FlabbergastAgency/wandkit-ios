#if os(iOS)
import SwiftUI

public struct WandKitTheme: Sendable {
    public var accentColor: Color
    public var starSelectedColor: Color
    public var starUnselectedColor: Color
    public var modalCornerRadius: CGFloat
    public var buttonCornerRadius: CGFloat

    public init(
        accentColor: Color = Color(uiColor: .tintColor),
        starSelectedColor: Color = Color(uiColor: .systemYellow),
        starUnselectedColor: Color = Color(uiColor: .secondaryLabel),
        modalCornerRadius: CGFloat = 20,
        buttonCornerRadius: CGFloat = 12
    ) {
        self.accentColor = accentColor
        self.starSelectedColor = starSelectedColor
        self.starUnselectedColor = starUnselectedColor
        self.modalCornerRadius = modalCornerRadius
        self.buttonCornerRadius = buttonCornerRadius
    }

    public static let `default` = WandKitTheme()
}
#endif
