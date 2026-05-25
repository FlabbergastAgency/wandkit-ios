import Foundation

struct ReferralMatchResponse: Decodable {
    let referralId: String
    let installId: String
    let claimMethod: String
    let claimedAt: Date
    let referral: MatchedReferral
}

extension ReferralMatchResponse {
    struct MatchedReferral: Decodable {
        let publicId: String
        let campaignKey: String
        let campaignName: String?
        let campaignImageUrl: String?
        let inviterId: String
        let code: String?
        let shortPath: String
        let properties: [String: JSONValue]?
        let status: String
        let usageMode: String
        let maxUses: Int?
        let claimedCount: Int
        let expiresAt: Date?
        let createdAt: Date
        let updatedAt: Date
    }
}
