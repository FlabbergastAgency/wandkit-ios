import Foundation

struct CreateReferralResponse: Decodable {
    let referralId: String
    let code: String
    let shortPath: String
    let campaign: String
    let createdAt: Date
    let expiresAt: Date
}
