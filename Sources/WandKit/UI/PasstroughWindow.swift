#if os(iOS)
import SwiftUI
import UIKit

final class PasstroughWindow: UIWindow {
    init(
        windowScene: UIWindowScene,
        response: EventResponse,
        theme: WandKitTheme = .default,
        onSubmit: @escaping @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void,
        onDismiss: @escaping @Sendable () async -> Void
    ) {
        super.init(windowScene: windowScene)

        update(response: response, theme: theme, onSubmit: onSubmit, onDismiss: onDismiss)
        backgroundColor = .clear
        windowLevel = .alert + 1
        isHidden = false
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(
        response: EventResponse,
        theme: WandKitTheme = .default,
        onSubmit: @escaping @Sendable ([SubmitFormResponseRequest.Answer]) async -> Void,
        onDismiss: @escaping @Sendable () async -> Void
    ) {
        let viewController = UIHostingController(
            rootView: WandKitView(response: response, onSubmit: onSubmit, onDismiss: onDismiss)
                .environment(\.wandKitTheme, theme)
        )
        viewController.view.backgroundColor = .clear
        rootViewController = viewController
    }

    private static func _hitTest(
        _ point: CGPoint,
        with event: UIEvent?,
        view: UIView,
        depth: Int = 0
    ) -> (view: UIView, depth: Int)? {
        var deepest: (view: UIView, depth: Int)? = .none
        let subviews = view.subviews.reversed()
        for subview in subviews {
            let converted = view.convert(point, to: subview)

            guard subview.isUserInteractionEnabled,
                  !subview.isHidden,
                  subview.alpha > 0
            else {
                continue
            }

            let result = if let hit = Self._hitTest(
                converted,
                with: event,
                view: subview,
                depth: depth + 1
            ) {
                hit
            } else {
                (view: subview, depth: depth)
            }

            if case .none = deepest {
                deepest = result
            } else if let current = deepest, result.depth > current.depth {
                deepest = result
            }
        }

        return deepest
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let rootView = rootViewController?.view else { return false }
        let hit = Self._hitTest(point, with: event, view: rootView)
        return hit != nil
    }
}
#endif
