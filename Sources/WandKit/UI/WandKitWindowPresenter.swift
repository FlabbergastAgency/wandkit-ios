#if os(iOS)
import UIKit

@MainActor
enum WandKitWindowPresenter {
    private static var window: PasstroughWindow?
    private static weak var previousKeyWindow: UIWindow?

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
            window.makeKeyAndVisible()
            return
        }

        previousKeyWindow = windowScene.windows.first(where: \.isKeyWindow)

        let newWindow = PasstroughWindow(
            windowScene: windowScene,
            response: response,
            theme: theme,
            onSubmit: onSubmit,
            onDismiss: onDismiss
        )
        newWindow.makeKeyAndVisible()
        window = newWindow
    }

    static func dismiss() {
        previousKeyWindow?.makeKey()
        previousKeyWindow = nil
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
