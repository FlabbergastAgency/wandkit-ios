import Foundation

final class WandKitStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var configuration = WandKitConfiguration()
    let httpClient: HTTPClient

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
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
}
