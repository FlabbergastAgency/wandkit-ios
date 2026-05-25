import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum WandKitDeviceInfo {
    static func makeMatchRequest(installId: String, firstLaunchAt: Date) -> ReferralMatchRequest {
        let context = makeReferralClientContext()
        return ReferralMatchRequest(
            installId: installId,
            userAgent: context.userAgent,
            language: context.language,
            languages: context.languages,
            timezone: context.timezone,
            timezoneOffsetMinutes: context.timezoneOffsetMinutes,
            platform: context.platform,
            screenWidth: context.screenWidth,
            screenHeight: context.screenHeight,
            viewportWidth: context.viewportWidth,
            viewportHeight: context.viewportHeight,
            devicePixelRatio: context.devicePixelRatio,
            clientTimestamp: context.clientTimestamp,
            extra: [
                "first_launch_at": .string(iso8601String(from: firstLaunchAt))
            ]
        )
    }

    static func makeCaptureFingerprintRequest(referralId: String) -> CaptureReferralFingerprintRequest {
        let context = makeReferralClientContext()
        return CaptureReferralFingerprintRequest(
            referralId: referralId,
            userAgent: context.userAgent,
            language: context.language,
            languages: context.languages,
            timezone: context.timezone,
            timezoneOffsetMinutes: context.timezoneOffsetMinutes,
            platform: context.platform,
            screenWidth: context.screenWidth,
            screenHeight: context.screenHeight,
            viewportWidth: context.viewportWidth,
            viewportHeight: context.viewportHeight,
            devicePixelRatio: context.devicePixelRatio,
            clientTimestamp: context.clientTimestamp,
            extra: nil
        )
    }

    private static var platform: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "unknown"
        #endif
    }

    private static var userAgent: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        let version = "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
        return "WandKit/\(WandKitConstants.sdkVersion) (\(platform) \(version); \(deviceModel))"
    }

    private static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 1) { cCharPtr in
                String(cString: cCharPtr)
            }
        }
    }

    private static var language: String {
        Locale.preferredLanguages.first ?? Locale.current.identifier
    }

    private static var languages: [String] {
        Locale.preferredLanguages
    }

    private static var screen: (width: Int, height: Int, dpr: Double) {
        #if os(iOS)
        let bounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        return (Int(bounds.width), Int(bounds.height), Double(scale))
        #elseif os(macOS)
        let screen = NSScreen.main
        let frame = screen?.frame ?? .zero
        let scale = screen?.backingScaleFactor ?? 1.0
        return (Int(frame.width), Int(frame.height), Double(scale))
        #else
        return (0, 0, 1.0)
        #endif
    }

    private static func iso8601String(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }

    private static func makeReferralClientContext() -> (
        userAgent: String,
        language: String,
        languages: [String],
        timezone: String,
        timezoneOffsetMinutes: Int,
        platform: String,
        screenWidth: Int,
        screenHeight: Int,
        viewportWidth: Int,
        viewportHeight: Int,
        devicePixelRatio: Double,
        clientTimestamp: Date
    ) {
        (
            userAgent: userAgent,
            language: language,
            languages: languages,
            timezone: TimeZone.current.identifier,
            timezoneOffsetMinutes: TimeZone.current.secondsFromGMT() / 60,
            platform: platform,
            screenWidth: screen.width,
            screenHeight: screen.height,
            viewportWidth: screen.width,
            viewportHeight: screen.height,
            devicePixelRatio: screen.dpr,
            clientTimestamp: Date()
        )
    }
}
