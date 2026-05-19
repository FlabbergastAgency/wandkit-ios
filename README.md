# WandKit iOS

The package currently targets:

- `iOS 15+`
- `macOS 10.15+`

## Installation

Add the package in Xcode with **File -> Add Package Dependencies...** and use:

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

## Quick Start

```swift
import WandKit

WandKit.configure(apiKey: "your-api-key")
WandKit.identify("user_123")

WandKit.event(
    "checkout_completed",
    properties: [
        "plan": "pro",
        "source": "paywall"
    ]
)
```

## Public API

`WandKit` exposes three main entry points:

- `WandKit.configure(apiKey:)`
- `WandKit.identify(_:)`
- `WandKit.event(_:properties:occurredAt:)`

## What `event(...)` Does

Calling `event(...)` triggers a feedback flow backed by `EventResponse` blocks. The current UI supports:

- star rating
- thumbs up / down
- multi-choice selection
- free-text input

On iOS, the feedback UI is presented in an overlay window above the current app interface.

## Current Status

This package is still under active development.

- `identify(...)` performs a real network request.
- `event(...)` currently returns a mock response in `WandKitService`, so the feedback form shown today is mock data.
- The overlay presentation is currently implemented only for iOS.

## Development Notes

- Swift tools version: `6.2`
- Library product: `WandKit`
- Debug builds print internal logs with the `[WandKit]` prefix
