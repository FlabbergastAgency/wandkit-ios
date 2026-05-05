#if os(iOS)
import UIKit

@MainActor
enum WandKitWindowPresenter {
    private static var window: PasstroughWindow?

    static func present(
        response: EventResponse,
        onSubmit: @escaping @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void,
        onDismiss: @escaping @Sendable () async -> Void
    ) {
        WandKitLogger.debug("Present requested")
        guard let windowScene = activeWindowScene() else { return }

        UIApplication.shared.sendAction(
            #selector(UIApplication.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        if let window, window.windowScene === windowScene {
            WandKitLogger.debug("Reusing existing window")
            window.update(response: response, onSubmit: onSubmit, onDismiss: onDismiss)
            window.isHidden = false
            return
        }

        WandKitLogger.debug("Creating a new window for presentation")
        let newWindow = PasstroughWindow(
            windowScene: windowScene,
            response: response,
            onSubmit: onSubmit,
            onDismiss: onDismiss
        )
        window = newWindow
    }

    static func dismiss() {
        WandKitLogger.debug("Dismiss requested")
        window?.isHidden = true
        window = nil
    }

    private static func activeWindowScene() -> UIWindowScene? {
        WandKitLogger.debug("Searching for active window scene")
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        if let keyWindowScene = scenes.first(where: { scene in
            scene.activationState == .foregroundActive &&
                scene.windows.contains(where: \.isKeyWindow)
        }) {
            WandKitLogger.debug("Found key window scene")
            return keyWindowScene
        }

        WandKitLogger.debug("Falling back to foreground scene search")
        return scenes.first(where: { $0.activationState == .foregroundActive })
            ?? scenes.first(where: { $0.activationState == .foregroundInactive })
    }
}
#endif
