import Foundation

public struct ReferralMatch: Sendable {
    public let referralId: String
    public let installId: String
    public let claimMethod: String
    public let claimedAt: Date
    public let inviterId: String
    public let campaign: String
    public let campaignName: String?
    public let code: String?
    public let shortPath: String
    public let properties: [String: String]
}
