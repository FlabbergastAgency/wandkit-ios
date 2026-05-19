import Foundation

struct WandKitConfiguration {
    var apiKey: String?
    var externalUserId: String?
    var deviceId = UUID().uuidString
    #if os(iOS)
    var theme: WandKitTheme = .default
    #endif
}
