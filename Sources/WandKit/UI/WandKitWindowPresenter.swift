#if os(iOS)
import UIKit

@MainActor
enum WandKitWindowPresenter {
    private static var window: PasstroughWindow?

    static func present(
        response: EventResponse,
        theme: WandKitTheme = .default,
        onSubmit: @escaping @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void,
        onDismiss: @escaping @Sendable () async -> Void
    ) {
        guard let windowScene = activeWindowScene() else { return }

        UIApplication.shared.sendAction(
            #selector(UIApplication.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )

        if let window, window.windowScene === windowScene {
            window.update(response: response, theme: theme, onSubmit: onSubmit, onDismiss: onDismiss)
            window.isHidden = false
            return
        }

        let newWindow = PasstroughWindow(
            windowScene: windowScene,
            response: response,
            theme: theme,
            onSubmit: onSubmit,
            onDismiss: onDismiss
        )
        window = newWindow
    }

    static func dismiss() {
        window?.isHidden = true
        window = nil
    }

    private static func activeWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        if let keyWindowScene = scenes.first(where: { scene in
            scene.activationState == .foregroundActive &&
                scene.windows.contains(where: \.isKeyWindow)
        }) {
            return keyWindowScene
        }

        return scenes.first(where: { $0.activationState == .foregroundActive })
            ?? scenes.first(where: { $0.activationState == .foregroundInactive })
    }
}
#endif
