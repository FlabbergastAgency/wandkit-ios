import Foundation

enum WandKitConstants {
    static let baseURL = URL(string: "http://192.168.1.32:8081")!
    static let identifyPath = "identify"
    static let ratePath = "rate"
    static let eventsPathComponents = ["api", "v1", "sdk", "events"]
    static let apiKeyHeader = "X-API-Key"

    static let identifyURL = baseURL.appendingPathComponent(identifyPath)
    static let rateURL = baseURL.appendingPathComponent(ratePath)
    static let eventsURL = eventsPathComponents.reduce(baseURL) { url, component in
        url.appendingPathComponent(component)
    }
}
