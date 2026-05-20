import Foundation

struct CreateReferralRequest: Encodable {
    let userId: String
    let campaign: String
    let properties: [String: String]?
}
