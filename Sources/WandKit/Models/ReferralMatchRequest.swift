import Foundation

struct ReferralMatchRequest: Encodable {
    let installId: String
    let fingerprint: Fingerprint
    let sdkVersion: String
}

extension ReferralMatchRequest {
    struct Fingerprint: Encodable {
        let os: String
        let osVersion: String
        let deviceModel: String
        let deviceClass: String
        let language: String
        let languages: [String]
        let timezone: String
        let timezoneOffset: Int
        let screen: Screen
        let carrierCountry: String?
        let firstLaunchAt: Date
    }

    struct Screen: Encodable {
        let width: Int
        let height: Int
        let dpr: Double
    }
}
