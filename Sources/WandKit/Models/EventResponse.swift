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
                    placeholder: nil,
                    next: [.init(pageId: "recommendation", condition: nil)]
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
                    placeholder: nil,
                    next: [.init(pageId: "highlights", condition: nil)]
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
                    placeholder: nil,
                    next: [.init(pageId: "feedback", condition: nil)]
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
                    placeholder: "Write your feedback here",
                    next: [.init(pageId: "done", condition: nil)]
                ),
                .init(
                    id: "done",
                    type: .end,
                    title: "Thanks for your feedback!",
                    subtitle: nil,
                    imageUrl: nil,
                    nextButtonLabel: nil,
                    required: false,
                    options: nil,
                    allowMultiple: nil,
                    maxLength: nil,
                    placeholder: nil,
                    next: []
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
        public let next: [NextRule]

        private enum CodingKeys: String, CodingKey {
            case id
            case type
            case title
            case subtitle
            case imageUrl
            case nextButtonLabel
            case required
            case options
            case allowMultiple
            case maxLength
            case placeholder
            case next
        }

        public init(
            id: String,
            type: PageType,
            title: String,
            subtitle: String?,
            imageUrl: String?,
            nextButtonLabel: String?,
            required: Bool,
            options: [Option]?,
            allowMultiple: Bool?,
            maxLength: Int?,
            placeholder: String?,
            next: [NextRule]
        ) {
            self.id = id
            self.type = type
            self.title = title
            self.subtitle = subtitle
            self.imageUrl = imageUrl
            self.nextButtonLabel = nextButtonLabel
            self.required = required
            self.options = options
            self.allowMultiple = allowMultiple
            self.maxLength = maxLength
            self.placeholder = placeholder
            self.next = next
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            type = try container.decode(PageType.self, forKey: .type)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
            imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            nextButtonLabel = try container.decodeIfPresent(String.self, forKey: .nextButtonLabel)
            required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
            options = try container.decodeIfPresent([Option].self, forKey: .options)
            allowMultiple = try container.decodeIfPresent(Bool.self, forKey: .allowMultiple)
            maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
            placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
            next = try container.decodeIfPresent([NextRule].self, forKey: .next) ?? []
        }
    }

    public struct NextRule: Decodable, Sendable {
        public let pageId: String
        public let condition: String?

        private enum CodingKeys: String, CodingKey {
            case pageId
            case condition
        }

        public init(pageId: String, condition: String?) {
            self.pageId = pageId
            self.condition = condition
        }
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
        case end
    }
}
