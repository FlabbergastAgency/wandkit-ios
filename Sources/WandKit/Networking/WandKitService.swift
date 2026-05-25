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
        campaignKey: String,
        properties: [String: String]?
    ) async throws -> ReferralInfo {
        let requestProperties = properties?.reduce(into: [String: JSONValue]()) { partialResult, entry in
            partialResult[entry.key] = .string(entry.value)
        }

        let response = try await storage.httpClient.post(
            to: WandKitConstants.referralsURL,
            headers: headers(),
            body: CreateReferralRequest(
                campaignKey: campaignKey,
                userId: userId,
                properties: requestProperties,
                expiresAt: nil,
                usageMode: nil,
                maxUses: nil
            ),
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
            url: decoded.url,
            campaign: decoded.campaign,
            campaignName: decoded.campaignName,
            campaignImageUrl: decoded.campaignImageUrl,
            projectName: decoded.projectName,
            inviterId: decoded.inviterId,
            status: decoded.status,
            usageMode: decoded.usageMode,
            maxUses: decoded.maxUses,
            claimedCount: decoded.claimedCount,
            createdAt: decoded.createdAt,
            expiresAt: decoded.expiresAt,
            updatedAt: decoded.updatedAt
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

    func captureReferralFingerprint(referralId: String) async throws {
        let request = WandKitDeviceInfo.makeCaptureFingerprintRequest(referralId: referralId)
        let response = try await storage.httpClient.post(
            to: WandKitConstants.referralFingerprintURL(),
            headers: headers(),
            body: request,
            encoder: requestEncoder()
        )

        guard (200 ..< 300).contains(response.response.statusCode) else {
            WandKitLogger.debug("Capture referral fingerprint failed with statusCode=\(response.response.statusCode)")
            throw HTTPClientError.invalidStatusCode(response.response.statusCode)
        }
    }

    func matchReferral() async throws -> ReferralMatch? {
        let request = WandKitDeviceInfo.makeMatchRequest(
            installId: storage.installId,
            firstLaunchAt: storage.firstLaunchAt
        )
        let response = try await storage.httpClient.post(
            to: WandKitConstants.referralMatchURL,
            headers: headers(),
            body: request,
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
            installId: decoded.installId,
            claimMethod: decoded.claimMethod,
            claimedAt: decoded.claimedAt,
            inviterId: decoded.referral.inviterId,
            campaign: decoded.referral.campaignKey,
            campaignName: decoded.referral.campaignName,
            code: decoded.referral.code,
            shortPath: decoded.referral.shortPath,
            properties: makeStringProperties(decoded.referral.properties)
        )
    }

    func redeemCode(_ code: String) async throws -> ReferralMatch {
        let response = try await storage.httpClient.post(
            to: WandKitConstants.redeemCodeURL,
            headers: headers(),
            body: RedeemCodeRequest(
                installId: storage.installId,
                code: code
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
            installId: decoded.installId,
            claimMethod: decoded.claimMethod,
            claimedAt: decoded.claimedAt,
            inviterId: decoded.referral.inviterId,
            campaign: decoded.referral.campaignKey,
            campaignName: decoded.referral.campaignName,
            code: decoded.referral.code,
            shortPath: decoded.referral.shortPath,
            properties: makeStringProperties(decoded.referral.properties)
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
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            if let date = formatter.date(from: value) {
                return date
            }

            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date string: \(value)"
            )
        }
        return decoder
    }

    private func makeStringProperties(_ properties: [String: JSONValue]?) -> [String: String] {
        guard let properties else {
            return [:]
        }

        return properties.reduce(into: [String: String]()) { partialResult, entry in
            partialResult[entry.key] = entry.value.stringValue ?? "null"
        }
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
