import Foundation

enum WandKitConstants {
    static let appBaseURL = URL(string: "https://app.wandkit.flabic.com")!
    static let apiBaseURL = URL(string: "https://api.wandkit.flabic.com")!
    static let identifyPath = "identify"
    static let ratePath = "rate"
    static let eventsPathComponents = ["api", "v1", "sdk", "events"]
    static let formsPathComponents = ["api", "v1", "sdk", "forms"]
    static let referralsPathComponents = ["api", "v1", "referrals"]
    static let referralMatchPathComponents = ["v1", "referrals", "match"]
    static let redeemCodePathComponents = ["v1", "code", "redeem"]
    static let apiKeyHeader = "X-API-Key"
    static let sdkVersion = "ios-0.1.1"

    static let identifyURL = appBaseURL.appendingPathComponent(identifyPath)
    static let rateURL = appBaseURL.appendingPathComponent(ratePath)
    static let eventsURL = eventsPathComponents.reduce(apiBaseURL) { url, component in
        url.appendingPathComponent(component)
    }
    static let referralsURL = referralsPathComponents.reduce(apiBaseURL) { url, component in
        url.appendingPathComponent(component)
    }
    static let referralMatchURL = referralMatchPathComponents.reduce(apiBaseURL) { url, component in
        url.appendingPathComponent(component)
    }
    static let redeemCodeURL = redeemCodePathComponents.reduce(apiBaseURL) { url, component in
        url.appendingPathComponent(component)
    }

    static func referralURL(path: String) -> URL {
        referralsURL.appendingPathComponent(path)
    }

    static func referralFingerprintURL() -> URL {
        referralsURL.appendingPathComponent("fingerprint")
    }

    static func submitFormResponseURL(impressionId: String) -> URL {
        formURL(impressionId: impressionId)
            .appendingPathComponent("response")
    }

    static func dismissFormURL(impressionId: String) -> URL {
        formURL(impressionId: impressionId)
            .appendingPathComponent("dismiss")
    }

    private static func formURL(impressionId: String) -> URL {
        formsPathComponents.reduce(apiBaseURL) { url, component in
            url.appendingPathComponent(component)
        }
        .appendingPathComponent(impressionId)
    }
}
