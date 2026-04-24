import Foundation

struct EventRequest: Encodable {
    let eventName: String
    let user: User
    let properties: [String: String]?
    let occurredAt: Date
    let sdk = SDK(platform: "ios", version: "1.4.0")
}

extension EventRequest {
    struct User: Encodable {
        let externalUserId: String
        let deviceId: String
    }

    struct SDK: Encodable {
        let platform: String
        let version: String
    }
}
