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
        guard view.isUserInteractionEnabled,
              !view.isHidden,
              view.alpha > 0,
              view.point(inside: point, with: event)
        else {
            return nil
        }

        var deepest: (view: UIView, depth: Int)? = .none
        let subviews = view.subviews.reversed()
        for subview in subviews {
            let converted = view.convert(point, to: subview)

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

        if let deepest {
            return deepest
        }

        return (view: view, depth: depth)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 18, *) {
            guard let rootView = rootViewController?.view else {
                return false
            }

            let hit = Self._hitTest(
                point,
                with: event,
                view: subviews.count > 1 ? self : rootView
            )

            if hit != nil {
                return true
            }

            return super.point(inside: point, with: event)
        } else {
            return super.point(inside: point, with: event)
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if #available(iOS 18, *) {
            return super.hitTest(point, with: event)
        } else {
            guard let hit = super.hitTest(point, with: event) else {
                return nil
            }

            return rootViewController?.view == hit ? nil : hit
        }
    }
}
#endif
