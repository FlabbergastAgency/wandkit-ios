import Foundation

struct ReferralMatchResponse: Decodable {
    let referralId: String
    let inviterId: String
    let campaign: String
    let properties: [String: String]?
}
