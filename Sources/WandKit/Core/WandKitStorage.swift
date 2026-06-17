import Foundation

final class WandKitStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var configuration = WandKitConfiguration()
    let httpClient: HTTPClient

    private enum Keys {
        static let installId = "wandkit.installId"
        static let firstLaunchAt = "wandkit.firstLaunchAt"
    }

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
        initializePersistentIds()
    }

    private func initializePersistentIds() {
        let defaults = UserDefaults.standard
        if defaults.string(forKey: Keys.installId) == nil {
            defaults.set(UUID().uuidString, forKey: Keys.installId)
        }
        if defaults.object(forKey: Keys.firstLaunchAt) == nil {
            defaults.set(Date(), forKey: Keys.firstLaunchAt)
        }
    }

    var installId: String {
        UserDefaults.standard.string(forKey: Keys.installId) ?? UUID().uuidString
    }

    var firstLaunchAt: Date {
        (UserDefaults.standard.object(forKey: Keys.firstLaunchAt) as? Date) ?? Date()
    }

    var apiKey: String? {
        lock.withLock {
            configuration.apiKey
        }
    }

    var externalUserId: String? {
        lock.withLock {
            configuration.externalUserId
        }
    }

    var deviceId: String {
        lock.withLock {
            configuration.deviceId
        }
    }

    var environment: WandKit.Environment {
        lock.withLock {
            configuration.environment
        }
    }

    func setAPIKey(_ apiKey: String) {
        lock.withLock {
            configuration.apiKey = apiKey
        }
    }

    func setExternalUserId(_ externalUserId: String) {
        lock.withLock {
            configuration.externalUserId = externalUserId
        }
    }

    func setEnvironment(_ environment: WandKit.Environment) {
        lock.withLock {
            configuration.environment = environment
        }
    }

    #if os(iOS)
    var theme: WandKitTheme {
        lock.withLock {
            configuration.theme
        }
    }

    func setTheme(_ theme: WandKitTheme) {
        lock.withLock {
            configuration.theme = theme
        }
    }
    #endif
}
