import Foundation

struct WandKitConfiguration {
    var apiKey: String?
    var externalUserId: String?
    var deviceId = UUID().uuidString
    var environment: WandKit.Environment = .production
    #if os(iOS)
    var theme: WandKitTheme = .default
    #endif
}
