import Foundation

extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        WandKitLogger.debug("Acquiring lock")
        lock()
        defer {
            WandKitLogger.debug("Releasing lock")
            unlock()
        }
        return body()
    }
}
