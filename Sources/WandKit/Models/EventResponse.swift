import Foundation

public struct EventResponse: Decodable, Sendable {
    public let eventId: String
    public let form: Form
}

extension EventResponse {
    public static let mock = Self(
        eventId: "evt_mock_123",
        form: .init(
            publicId: "form_public_mock",
            impressionId: "imp_mock_123",
            title: "How was your experience?",
            description: "Tell us what went well and what we can improve.",
            blocks: [
                .init(
                    id: "rating",
                    type: .stars,
                    label: "Rate your experience",
                    required: true,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: nil,
                    placeholder: nil
                ),
                .init(
                    id: "recommendation",
                    type: .thumbs,
                    label: "Would you recommend this to a friend?",
                    required: true,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: nil,
                    placeholder: nil
                ),
                .init(
                    id: "highlights",
                    type: .multiChoice,
                    label: "What stood out the most?",
                    required: false,
                    options: [
                        .init(id: "speed", label: "Fast"),
                        .init(id: "design", label: "Design"),
                        .init(id: "support", label: "Support")
                    ],
                    allowMultiple: true,
                    maxLength: nil,
                    placeholder: nil
                ),
                .init(
                    id: "feedback",
                    type: .text,
                    label: "Anything else you'd like to share?",
                    required: false,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: 280,
                    placeholder: "Write your feedback here"
                )
            ]
        )
    )
}

extension EventResponse {
    public struct Form: Decodable, Sendable {
        public let publicId: String
        public let impressionId: String
        public let title: String
        public let description: String
        public let blocks: [Block]
    }

    public struct Block: Decodable, Sendable {
        public let id: String
        public let type: BlockType
        public let label: String
        public let required: Bool
        public let options: [Option]?
        public let allowMultiple: Bool?
        public let maxLength: Int?
        public let placeholder: String?
    }

    public struct Option: Decodable, Sendable {
        public let id: String
        public let label: String
    }

    public enum BlockType: String, Decodable, Sendable {
        case thumbs
        case stars
        case multiChoice = "multi_choice"
        case text
    }
}
