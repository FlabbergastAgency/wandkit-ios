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
            pages: [
                .init(
                    id: "rating",
                    type: .stars,
                    title: "Rate your experience",
                    subtitle: "How did this feel overall?",
                    imageUrl: nil,
                    nextButtonLabel: "Next",
                    required: true,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: nil,
                    placeholder: nil
                ),
                .init(
                    id: "recommendation",
                    type: .thumbs,
                    title: "Would you recommend this to a friend?",
                    subtitle: nil,
                    imageUrl: nil,
                    nextButtonLabel: "Next",
                    required: true,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: nil,
                    placeholder: nil
                ),
                .init(
                    id: "highlights",
                    type: .multiChoice,
                    title: "What stood out the most?",
                    subtitle: "Pick any that apply.",
                    imageUrl: nil,
                    nextButtonLabel: "Confirm",
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
                    title: "Anything else you'd like to share?",
                    subtitle: nil,
                    imageUrl: nil,
                    nextButtonLabel: "Send",
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
        public let pages: [Page]
    }

    public struct Page: Decodable, Sendable {
        public let id: String
        public let type: PageType
        public let title: String
        public let subtitle: String?
        public let imageUrl: String?
        public let nextButtonLabel: String?
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

    public enum PageType: String, Decodable, Sendable {
        case thumbs
        case stars
        case multiChoice = "multi_choice"
        case text
    }
}
