import Foundation

struct GetReferralResponse: Decodable {
    let referralId: String
    let code: String
    let url: String
    let campaign: String
    let createdAt: Date
    let expiresAt: Date
    let qrCodeUrl: String
    let properties: [String: String]?
}
