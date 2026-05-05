import Foundation

struct SubmitFormResponseRequest: Encodable, Sendable {
    let answers: [Answer]
    let completedAt: Date
}

extension SubmitFormResponseRequest {
    struct Answer: Encodable, Sendable {
        let pageId: String
        let thumb: Thumb?
        let stars: Int?
        let selectedOptionIds: [String]?
        let text: String?
    }

    enum Thumb: String, Encodable, Sendable {
        case up
        case down
    }
}
