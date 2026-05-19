import Foundation

public enum WandKit {
    private static let storage = WandKitStorage()
    private static let service = WandKitService(storage: storage)

    public static func configure(apiKey: String) {
        WandKitLogger.debug("Configuring API key")
        storage.setAPIKey(apiKey)
    }

    #if os(iOS)
    public static func configure(apiKey: String, theme: WandKitTheme) {
        configure(apiKey: apiKey)
        storage.setTheme(theme)
    }
    #endif

    public static func identify(_ userId: String) {
        WandKitLogger.debug("Scheduling identify for userId=\(userId)")
        storage.setExternalUserId(userId)
        Task {
            WandKitLogger.debug("Executing identify task for userId=\(userId)")
            try? await service.identify(userId: userId)
        }
    }

    public static func event(
        _ eventName: String,
        properties: [String: String]? = nil,
        occurredAt: Date = Date()
    ) {
        WandKitLogger.debug("Executing event for eventName=\(eventName)")
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
