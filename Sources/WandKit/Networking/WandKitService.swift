import Foundation

@available(iOS 14.0, macOS 10.15, *)
struct WandKitService: Sendable {
    private let storage: WandKitStorage

    init(storage: WandKitStorage) {
        WandKitLogger.debug("Initializing service")
        self.storage = storage
    }

    func identify(userId: String) async throws {
        WandKitLogger.debug("Sending identify request for userId=\(userId)")
        _ = try await storage.httpClient.post(
            to: WandKitConstants.identifyURL,
            headers: headers(),
            body: IdentifyRequest(userId: userId),
            encoder: JSONEncoder()
        )
        WandKitLogger.debug("Identify request completed")
    }

    func event(
        eventName: String,
        properties: [String: String]? = nil,
        occurredAt: Date = Date()
    ) async throws -> EventResponse {
        let externalUserId = storage.externalUserId.flatMap { value in
            value.isEmpty ? nil : value
        } ?? UUID().uuidString

        WandKitLogger.debug("Sending event request for eventName=\(eventName)")
        let response = try await storage.httpClient.post(
            to: WandKitConstants.eventsURL,
            headers: headers(),
            body: EventRequest(
                eventName: eventName,
                user: .init(
                    externalUserId: externalUserId,
                    deviceId: storage.deviceId
                ),
                properties: properties,
                occurredAt: occurredAt
            ),
            encoder: requestEncoder()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Event request failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        WandKitLogger.debug("Event request completed with event response")
        return try responseDecoder().decode(EventResponse.self, from: response.data)
    }

    func submitFormResponse(
        impressionId: String,
        answers: [SubmitFormResponseRequest.Answer],
        completedAt: Date = Date()
    ) async throws {
        WandKitLogger.debug("Submitting form response for impressionId=\(impressionId)")
        let response = try await storage.httpClient.post(
            to: WandKitConstants.submitFormResponseURL(impressionId: impressionId),
            headers: headers(),
            body: SubmitFormResponseRequest(
                answers: answers,
                completedAt: completedAt
            ),
            encoder: requestEncoder()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Submit form response failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        WandKitLogger.debug("Submit form response completed")
    }

    func dismissForm(impressionId: String) async throws {
        WandKitLogger.debug("Dismissing form for impressionId=\(impressionId)")
        let response = try await storage.httpClient.post(
            to: WandKitConstants.dismissFormURL(impressionId: impressionId),
            headers: headers(),
            body: nil
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Dismiss form failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        WandKitLogger.debug("Dismiss form completed")
    }

    func rate(flowName: String) async throws {
        WandKitLogger.debug("Sending rate request for flowName=\(flowName)")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        WandKitLogger.debug("Rate request completed")

        #if os(iOS)
        WandKitLogger.debug("Presenting WandKit window")
        await WandKitWindowPresenter.present(
            response: .mock,
            onSubmit: { _ in },
            onDismiss: {}
        )
        #endif
    }

    private func headers() -> [String: String] {
        WandKitLogger.debug("Building request headers")
        guard let apiKey = storage.apiKey, !apiKey.isEmpty else {
            WandKitLogger.debug("No API key available")
            return [:]
        }

        WandKitLogger.debug("Using API key header")
        return [WandKitConstants.apiKeyHeader: apiKey]
    }

    private func requestEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let value = formatter.string(from: date)
            try container.encode(value)
        }
        return encoder
    }

    private func responseDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
