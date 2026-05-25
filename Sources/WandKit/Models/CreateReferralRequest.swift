import Foundation

struct CreateReferralRequest: Encodable {
    let campaignKey: String
    let userId: String
    let properties: [String: JSONValue]?
    let expiresAt: Date?
    let usageMode: String?
    let maxUses: Int?
}
