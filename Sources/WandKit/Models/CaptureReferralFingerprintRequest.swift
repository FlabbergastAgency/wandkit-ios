import Foundation

struct CaptureReferralFingerprintRequest: Encodable {
    let referralId: String
    let userAgent: String
    let language: String
    let languages: [String]
    let timezone: String
    let timezoneOffsetMinutes: Int
    let platform: String
    let screenWidth: Int
    let screenHeight: Int
    let viewportWidth: Int
    let viewportHeight: Int
    let devicePixelRatio: Double
    let clientTimestamp: Date
    let extra: [String: JSONValue]?
}
