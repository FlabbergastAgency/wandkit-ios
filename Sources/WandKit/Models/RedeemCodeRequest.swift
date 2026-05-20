import Foundation

struct RedeemCodeRequest: Encodable {
    let installId: String
    let code: String
    let sdkVersion: String
}
