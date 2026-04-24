import Foundation

enum WandKitLogger {
    static func debug(
        _ message: @autoclosure () -> String = "",
        function: StaticString = #function
    ) {
        guard _isDebugAssertConfiguration() else { return }

        let resolvedMessage = message()
        if resolvedMessage.isEmpty {
            print("[WandKit] \(function)")
            return
        }

        print("[WandKit] \(function): \(resolvedMessage)")
    }
}
