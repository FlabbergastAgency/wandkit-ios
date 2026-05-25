# WandKit iOS

The package currently targets:

- `iOS 15+`
- `macOS 10.15+`

## Installation

Add the package in Xcode with **File → Add Package Dependencies...** and use:

```text
https://github.com/FlabbergastAgency/wandkit-ios
```

Or declare it in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/FlabbergastAgency/wandkit-ios", from: "0.1.0")
]
```

Then add the product to your target:

```swift
.product(name: "WandKit", package: "wandkit-ios")
```

---

## Setup

### Configure

Call `configure` once at app startup, before calling any other WandKit function. On iOS you can optionally pass a theme.

```swift
import WandKit

// Basic
WandKit.configure(apiKey: "your-api-key")

// iOS with custom theme
WandKit.configure(apiKey: "your-api-key", theme: .default)
```

### Identify

Associate the current session with a user ID. Call this after sign-in or whenever the user becomes known.

```swift
WandKit.identify("user_123")
```

---

## Events & Surveys

Calling `event` sends the event to WandKit and, if a survey is configured for that event in the dashboard, presents the feedback form automatically on iOS.

```swift
WandKit.event("checkout_completed")

// With properties
WandKit.event(
    "onboarding_finished",
    properties: [
        "plan": "pro",
        "source": "paywall"
    ]
)

// With a specific timestamp
WandKit.event("session_ended", occurredAt: someDate)
```

The feedback UI supports:

- Star rating
- Thumbs up / down
- Multi-choice selection
- Free-text input

On iOS, the form is presented in an overlay window above the current app interface. Survey responses and dismissals are submitted automatically.

---

## Referrals

### Create a referral (inviter side)

Call `invite` when the user taps an "Invite a friend" button. Returns a `ReferralInfo` with the shareable link, code, and campaign details.

```swift
let referral = try await WandKit.invite(
    userId: "user_123",
    campaign: "friend_q4"
)

// Share referral.url or referral.code with the invitee
print(referral.url)    // https://ref.yourapp.com/Xk2nP
print(referral.code)   // 612948
```

**`ReferralInfo` fields:**

| Field | Type | Description |
|---|---|---|
| `referralId` | `String` | Unique referral ID |
| `code` | `String` | Short numeric/alphanumeric code |
| `shortPath` | `String` | Short path component of the referral URL |
| `url` | `String` | Full shareable URL |
| `campaign` | `String` | Campaign key |
| `campaignName` | `String` | Human-readable campaign name |
| `inviterId` | `String` | User ID of the referrer |
| `status` | `String` | `active`, `expired`, etc. |
| `usageMode` | `String` | `single_use` or `multi_use` |
| `maxUses` | `Int?` | Max claim count, nil if unlimited |
| `claimedCount` | `Int` | Number of times already claimed |
| `createdAt` | `Date` | |
| `expiresAt` | `Date?` | nil if the referral never expires |
| `updatedAt` | `Date` | |

---

### Match on install (invitee side)

Call `matchReferral` on first app launch to automatically attribute the install to a referral. Returns `nil` if no match is found.

```swift
// AppDelegate / App init
if let match = try await WandKit.matchReferral() {
    print("Referred by \(match.inviterId) via campaign \(match.campaign)")
    applyReward(match.properties)
}
```

**`ReferralMatch` fields:**

| Field | Type | Description |
|---|---|---|
| `referralId` | `String` | Matched referral ID |
| `installId` | `String` | This device's install ID |
| `claimMethod` | `String` | `fingerprint` or `code` |
| `claimedAt` | `Date` | When the claim was recorded |
| `inviterId` | `String` | User ID of the referrer |
| `campaign` | `String` | Campaign key |
| `campaignName` | `String?` | Human-readable campaign name |
| `code` | `String?` | Code used (if `claimMethod` is `code`) |
| `shortPath` | `String` | Short path of the matched referral |
| `properties` | `[String: String]` | Custom properties from the referral |

---

### Redeem a code (invitee side)

Call `redeemCode` when the user manually enters a referral code. Returns a `ReferralMatch` on success.

```swift
let match = try await WandKit.redeemCode("612948")
print("Redeemed referral from \(match.inviterId)")
```

---

### Fetch referral by path

Retrieve referral details using the short path from a deep link or landing page URL.

```swift
let details = try await WandKit.getReferral(path: "Xk2nP")
print(details.campaignName)
```

---

## Development Notes

- Swift tools version: `6.2`
- Library product: `WandKit`
- Debug builds print internal logs with the `[WandKit]` prefix
- `installId` and first-launch date are persisted in `UserDefaults` automatically on first SDK init
