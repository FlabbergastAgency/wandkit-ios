import Foundation

struct CreateReferralResponse: Decodable {
    let referralId: String
    let code: String
    let shortPath: String
    let url: String
    let campaign: String
    let campaignName: String
    let campaignImageUrl: String?
    let projectName: String?
    let properties: [String: JSONValue]?
    let inviterId: String
    let status: String
    let usageMode: String
    let maxUses: Int?
    let claimedCount: Int
    let createdAt: Date
    let expiresAt: Date?
    let updatedAt: Date
}
