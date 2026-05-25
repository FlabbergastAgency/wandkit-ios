import Foundation

public struct ReferralInfo: Sendable {
    public let referralId: String
    public let code: String
    public let shortPath: String
    public let url: String
    public let campaign: String
    public let campaignName: String
    public let campaignImageUrl: String?
    public let projectName: String?
    public let inviterId: String
    public let status: String
    public let usageMode: String
    public let maxUses: Int?
    public let claimedCount: Int
    public let createdAt: Date
    public let expiresAt: Date?
    public let updatedAt: Date
}
