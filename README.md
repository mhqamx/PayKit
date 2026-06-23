# PayKit

PayKit is an iOS payment SDK workspace for integrating WeChat Pay and Alipay
client payment flows behind a shared Swift and Objective-C public API.

## Workspace

```text
Sources/PayKit/Public/
Sources/PayKit/Core/
Sources/PayKit/Adapters/
Demos/SwiftDemo/
Demos/ObjCDemo/
Distribution/
```

The MVP deployment target for iOS is 15.0 or later. The Swift Package also
declares macOS for local package testing only; the SDK product target remains
the iOS PayKit SDK surface.

## Build Check

```sh
swift test
```

Future stories add the public `PYK*` Objective-C-visible API, Swift facade,
callback router, channel adapters, demos, CocoaPods support and XCFramework
distribution.
