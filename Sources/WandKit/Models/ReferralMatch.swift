import Foundation

public struct ReferralMatch: Sendable {
    public let referralId: String
    public let inviterId: String
    public let campaign: String
    public let properties: [String: String]
}
