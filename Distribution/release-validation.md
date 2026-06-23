# Release Validation

Candidate version: 0.1.0
Source commit: pending release commit
Minimum iOS: 15.0

## Completed Checks

- `swift build` passed.
- `swift test` passed with 17 XCTest tests and 0 failures.
- CocoaPods parsed `Distribution/PayKit.podspec` through `pod ipc spec`.
- Generated Objective-C compatibility header exposes:
  - `PYKPayKit`
  - `PYKWechatPayRequest`
  - `PYKAlipayPayRequest`
  - `setupWithWechat:alipay:`
  - `payWithRequest:completion:`
  - `handleOpenURL:`
  - `handleUserActivity:`
- Swift and Objective-C Demo sources only use PayKit public API for payment calls.

## Native SDK Boundary

WechatOpenSDK and AlipaySDK binaries are not vendored in this repository. PayKit
keeps the native payment launch behind adapter-private runtime bridges. If the
host app links the official native SDK artifacts, PayKit detects their standard
Objective-C classes/selectors and invokes the channel launch/callback APIs. If
they are not linked, PayKit returns explicit channel-specific unavailable
failures.

## Release Notes

- CocoaPods metadata and XCFramework build script are present for the release
  path. The XCFramework script requires an Xcode project/workspace container
  through `PAYKIT_XCODE_PROJECT` or `PAYKIT_XCODE_WORKSPACE`.
- Demo and README state that client `success` is not final merchant order
  success. Final order state belongs to the business backend.
- Before tagging a production release, run the same validation with the real
  WechatOpenSDK and AlipaySDK artifacts used by the host app.
