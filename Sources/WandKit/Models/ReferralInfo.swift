import Foundation

public struct ReferralInfo: Sendable {
    public let referralId: String
    public let code: String
    public let shortPath: String
    public let campaign: String
    public let createdAt: Date
    public let expiresAt: Date
}
