#if os(iOS)
import SwiftUI
import UIKit

public final class PasstroughWindow: UIWindow {
    public init(windowScene: UIWindowScene, response: EventResponse) {
        WandKitLogger.debug("Creating PasstroughWindow")
        super.init(windowScene: windowScene)

        update(response: response)
        backgroundColor = .clear
        windowLevel = .alert + 1
        isHidden = false
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        WandKitLogger.debug("init(coder:) is unsupported")
        fatalError("init(coder:) has not been implemented")
    }

    func update(response: EventResponse) {
        WandKitLogger.debug("Updating hosted WandKit view")
        let viewController = UIHostingController(rootView: WandKitView(response: response))
        viewController.view.backgroundColor = .clear
        rootViewController = viewController
    }

    private static func _hitTest(
        _ point: CGPoint,
        with event: UIEvent?,
        view: UIView,
        depth: Int = 0
    ) -> (view: UIView, depth: Int)? {
        WandKitLogger.debug("Hit-testing view=\(String(describing: type(of: view))) depth=\(depth)")
        var deepest: (view: UIView, depth: Int)? = .none
        let subviews = view.subviews.reversed()
        for subview in subviews {
            let converted = view.convert(point, to: subview)

            guard subview.isUserInteractionEnabled,
                  !subview.isHidden,
                  subview.alpha > 0
            else {
                WandKitLogger.debug("Skipping non-interactive subview")
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

        WandKitLogger.debug("Hit-test result found=\(deepest != nil)")
        return deepest
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        WandKitLogger.debug("Evaluating point-inside")
        guard let rootView = rootViewController?.view else { return false }
        let hit = Self._hitTest(point, with: event, view: rootView)
        WandKitLogger.debug("point(inside:with:) returning \(hit != nil)")
        return hit != nil
    }
}
#endif
