#if os(iOS)
import SwiftUI

struct WandKitThemeKey: EnvironmentKey {
    static let defaultValue = WandKitTheme.default
}

extension EnvironmentValues {
    var wandKitTheme: WandKitTheme {
        get { self[WandKitThemeKey.self] }
        set { self[WandKitThemeKey.self] = newValue }
    }
}
#endif
