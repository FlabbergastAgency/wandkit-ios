import Foundation

public struct GetReferralResponse: Decodable {
    public let referralId: String
    public let campaign: String
    public let campaignName: String?
    public let campaignImageUrl: String?
    public let projectName: String?
    public let properties: [String: JSONValue]?
    public let status: String
    public let expiresAt: Date?
}
