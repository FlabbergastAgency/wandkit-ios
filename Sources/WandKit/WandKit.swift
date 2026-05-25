import Foundation

public enum WandKit {
    private static let storage = WandKitStorage()
    private static let service = WandKitService(storage: storage)

    public static func configure(apiKey: String) {
        storage.setAPIKey(apiKey)
    }

    #if os(iOS)
    public static func configure(apiKey: String, theme: WandKitTheme) {
        configure(apiKey: apiKey)
        storage.setTheme(theme)
    }
    #endif

    public static func identify(_ userId: String) {
        storage.setExternalUserId(userId)
        Task {
            try? await service.identify(userId: userId)
        }
    }

    @discardableResult
    public static func invite(
        userId: String,
        campaign: String,
        properties: [String: String]? = nil
    ) async throws -> ReferralInfo {
        try await service.createReferral(userId: userId, campaignKey: campaign, properties: properties)
    }
    public static func getReferral(path: String) async throws -> GetReferralResponse {
        try await service.getReferral(path: path)
    }

    public static func captureReferralFingerprint(referralId: String) async throws {
        try await service.captureReferralFingerprint(referralId: referralId)
    }

    public static func matchReferral() async throws -> ReferralMatch? {
        try await service.matchReferral()
    }

    public static func redeemCode(_ code: String) async throws -> ReferralMatch {
        try await service.redeemCode(code)
    }

    public static func event(
        _ eventName: String,
        properties: [String: String]? = nil,
        occurredAt: Date = Date()
    ) {
        Task {
            let response = try await service.event(
                eventName: eventName,
                properties: properties,
                occurredAt: occurredAt
            )

            print(response)

            #if os(iOS)
            await WandKitWindowPresenter.present(
                response: response,
                theme: storage.theme,
                onSubmit: { answers in
                    do {
                        try await service.submitFormResponse(
                            impressionId: response.form.impressionId,
                            answers: answers
                        )
                    } catch {
                        WandKitLogger.debug("Submit form response failed: \(error.localizedDescription)")
                    }
                },
                onDismiss: {
                    do {
                        try await service.dismissForm(impressionId: response.form.impressionId)
                    } catch {
                        WandKitLogger.debug("Dismiss form failed: \(error.localizedDescription)")
                    }
                }
            )
            #endif
        }
    }
}
