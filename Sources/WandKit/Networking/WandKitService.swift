import Foundation

@available(iOS 14.0, macOS 10.15, *)
struct WandKitService: Sendable {
    private let storage: WandKitStorage

    init(storage: WandKitStorage) {
        self.storage = storage
    }

    func identify(userId: String) async throws {
        _ = try await storage.httpClient.post(
            to: WandKitConstants.identifyURL,
            headers: headers(),
            body: IdentifyRequest(userId: userId),
            encoder: JSONEncoder()
        )
    }

    func event(
        eventName: String,
        properties: [String: String]? = nil,
        occurredAt: Date = Date()
    ) async throws -> EventResponse {
        let externalUserId = storage.externalUserId.flatMap { value in
            value.isEmpty ? nil : value
        } ?? UUID().uuidString

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

        do {
            let decoded = try responseDecoder().decode(EventResponse.self, from: response.data)
            return decoded
        } catch let error as DecodingError {
            throw error
        }
    }

    func submitFormResponse(
        impressionId: String,
        answers: [SubmitFormResponseRequest.Answer],
        completedAt: Date = Date()
    ) async throws {
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

    }

    func dismissForm(impressionId: String) async throws {
        let response = try await storage.httpClient.post(
            to: WandKitConstants.dismissFormURL(impressionId: impressionId),
            headers: headers(),
            body: nil
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Dismiss form failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

    }

    func createReferral(
        userId: String,
        campaign: String,
        properties: [String: String]?
    ) async throws -> ReferralInfo {
        let response = try await storage.httpClient.post(
            to: WandKitConstants.referralsURL,
            headers: headers(),
            body: CreateReferralRequest(userId: userId, campaign: campaign, properties: properties),
            encoder: requestEncoder()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Create referral failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        let decoded = try responseDecoder().decode(CreateReferralResponse.self, from: response.data)
        return ReferralInfo(
            referralId: decoded.referralId,
            code: decoded.code,
            shortPath: decoded.shortPath,
            campaign: decoded.campaign,
            createdAt: decoded.createdAt,
            expiresAt: decoded.expiresAt
        )
    }

    func getReferral(path: String) async throws -> GetReferralResponse {
        let response = try await storage.httpClient.get(
            from: WandKitConstants.referralURL(path: path),
            headers: headers()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Get referral failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        return try responseDecoder().decode(GetReferralResponse.self, from: response.data)
    }

    func matchReferral() async throws -> ReferralMatch? {
        let fingerprint = WandKitDeviceInfo.makeMatchFingerprint(firstLaunchAt: storage.firstLaunchAt)
        let response = try await storage.httpClient.post(
            to: WandKitConstants.referralMatchURL,
            headers: headers(),
            body: ReferralMatchRequest(
                installId: storage.installId,
                fingerprint: fingerprint,
                sdkVersion: WandKitConstants.sdkVersion
            ),
            encoder: requestEncoder()
        )

        if response.response.statusCode == 404 {
            return nil
        }

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Match referral failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        let decoded = try responseDecoder().decode(ReferralMatchResponse.self, from: response.data)
        return ReferralMatch(
            referralId: decoded.referralId,
            inviterId: decoded.inviterId,
            campaign: decoded.campaign,
            properties: decoded.properties ?? [:]
        )
    }

    func redeemCode(_ code: String) async throws -> ReferralMatch {
        let response = try await storage.httpClient.post(
            to: WandKitConstants.redeemCodeURL,
            headers: headers(),
            body: RedeemCodeRequest(
                installId: storage.installId,
                code: code,
                sdkVersion: WandKitConstants.sdkVersion
            ),
            encoder: requestEncoder()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Redeem code failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }

        let decoded = try responseDecoder().decode(ReferralMatchResponse.self, from: response.data)
        return ReferralMatch(
            referralId: decoded.referralId,
            inviterId: decoded.inviterId,
            campaign: decoded.campaign,
            properties: decoded.properties ?? [:]
        )
    }

    func rate(flowName: String) async throws {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        #if os(iOS)
        await WandKitWindowPresenter.present(
            response: .mock,
            onSubmit: { _ in },
            onDismiss: {}
        )
        #endif
    }

    private func headers() -> [String: String] {
        guard let apiKey = storage.apiKey, !apiKey.isEmpty else {
            WandKitLogger.debug("No API key available")
            return [:]
        }

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

    private func debugJSONString(from data: Data) -> String {
        guard !data.isEmpty else {
            return "<empty>"
        }

        if let object = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }

        return String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count) bytes>"
    }

    private func formatDecodingError(_ error: DecodingError) -> String {
        switch error {
        case let .typeMismatch(type, context):
            return "typeMismatch(\(type), path=\(codingPathString(context.codingPath)), description=\(context.debugDescription))"
        case let .valueNotFound(type, context):
            return "valueNotFound(\(type), path=\(codingPathString(context.codingPath)), description=\(context.debugDescription))"
        case let .keyNotFound(key, context):
            return "keyNotFound(\(key.stringValue), path=\(codingPathString(context.codingPath)), description=\(context.debugDescription))"
        case let .dataCorrupted(context):
            return "dataCorrupted(path=\(codingPathString(context.codingPath)), description=\(context.debugDescription))"
        @unknown default:
            return String(describing: error)
        }
    }

    private func codingPathString(_ codingPath: [CodingKey]) -> String {
        guard !codingPath.isEmpty else {
            return "<root>"
        }

        return codingPath.map(\.stringValue).joined(separator: ".")
    }
}
