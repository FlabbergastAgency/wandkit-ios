import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum WandKitDeviceInfo {
    static func makeMatchFingerprint(firstLaunchAt: Date) -> ReferralMatchRequest.Fingerprint {
        ReferralMatchRequest.Fingerprint(
            os: osName,
            osVersion: osVersion,
            deviceModel: deviceModel,
            deviceClass: deviceClass,
            language: language,
            languages: languages,
            timezone: TimeZone.current.identifier,
            timezoneOffset: TimeZone.current.secondsFromGMT() / 60,
            screen: screen,
            carrierCountry: carrierCountry,
            firstLaunchAt: firstLaunchAt
        )
    }

    private static var osName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "unknown"
        #endif
    }

    private static var osVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
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

    private static var deviceClass: String {
        #if os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return "tablet"
        default: return "phone"
        }
        #elseif os(macOS)
        return "mac"
        #else
        return "unknown"
        #endif
    }

    private static var language: String {
        Locale.preferredLanguages.first ?? Locale.current.identifier
    }

    private static var languages: [String] {
        Locale.preferredLanguages
    }

    private static var screen: ReferralMatchRequest.Screen {
        #if os(iOS)
        let bounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        return ReferralMatchRequest.Screen(
            width: Int(bounds.width),
            height: Int(bounds.height),
            dpr: Double(scale)
        )
        #elseif os(macOS)
        let screen = NSScreen.main
        let frame = screen?.frame ?? .zero
        let scale = screen?.backingScaleFactor ?? 1.0
        return ReferralMatchRequest.Screen(
            width: Int(frame.width),
            height: Int(frame.height),
            dpr: Double(scale)
        )
        #else
        return ReferralMatchRequest.Screen(width: 0, height: 0, dpr: 1.0)
        #endif
    }

    private static var carrierCountry: String? {
        Locale.current.region?.identifier
    }
}
