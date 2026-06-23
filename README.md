# PayKit

PayKit is an iOS 15+ payment SDK that wraps WeChat Pay and Alipay client
payment flows behind one Swift and Objective-C public API.

The SDK only handles client-side launch, callback routing and result
normalization. A `success` result means the payment channel returned client-flow
success. The merchant app must still confirm the final order status with its
own backend.

## Swift

```swift
let wechat = PYKWechatConfig(appId: "wx-app-id", universalLink: "https://example.com/app/")
let alipay = PYKAlipayConfig(appScheme: "paykit-demo")

PayKit.setup(wechat: wechat, alipay: alipay)

let request = PYKAlipayPayRequest(orderString: orderStringFromBackend, appScheme: "paykit-demo")
PayKit.pay(request: request) { result in
    switch result.status {
    case .success:
        // Client flow succeeded. Confirm final order state with your backend.
        break
    case .cancelled:
        break
    case .failed:
        print(result.rawCode ?? "", result.rawMessage ?? "")
    @unknown default:
        break
    }
}
```

Forward lifecycle callbacks from your app delegate:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    PayKit.handleOpenURL(url)
}

func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    PayKit.handleUserActivity(userActivity)
}
```

## Objective-C

```objc
PYKWechatConfig *wechat = [[PYKWechatConfig alloc] initWithAppId:@"wx-app-id"
                                                   universalLink:@"https://example.com/app/"];
PYKAlipayConfig *alipay = [[PYKAlipayConfig alloc] initWithAppScheme:@"paykit-demo"];

[PYKPayKit setupWithWechat:wechat alipay:alipay];

PYKAlipayPayRequest *request = [[PYKAlipayPayRequest alloc] initWithOrderString:orderStringFromBackend
                                                                      appScheme:@"paykit-demo"];

[PYKPayKit payWithRequest:request completion:^(PYKPayResult *result) {
    if (result.status == PYKPayStatusSuccess) {
        // Client flow succeeded. Confirm final order state with your backend.
    } else if (result.status == PYKPayStatusCancelled) {
        // User cancelled.
    } else {
        NSLog(@"Pay failed: %@ %@", result.rawCode, result.rawMessage);
    }
}];
```

Forward URL callbacks:

```objc
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [PYKPayKit handleOpenURL:url];
}
```

## Demos

The repository includes complete iOS demo projects that customers can open in
Xcode:

```sh
open Demos/SwiftDemo/SwiftDemo.xcodeproj
open Demos/ObjCDemo/ObjCDemo.xcodeproj
```

Both demos use the local PayKit Swift Package dependency and include:

- app startup configuration for WeChat and Alipay
- URL Scheme and Universal Link forwarding
- WeChat typed request creation
- Alipay typed request creation
- unified result display

Build checks:

```sh
xcodebuild -project Demos/SwiftDemo/SwiftDemo.xcodeproj -scheme SwiftDemo -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
xcodebuild -project Demos/ObjCDemo/ObjCDemo.xcodeproj -scheme ObjCDemo -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

## Distribution

Build check:

```sh
swift test
```

CocoaPods work starts from `Distribution/PayKit.podspec`.
XCFramework output is produced by `Distribution/build-xcframework.sh` after
setting `PAYKIT_XCODE_PROJECT` or `PAYKIT_XCODE_WORKSPACE` plus
`PAYKIT_SCHEME`.

PayKit does not vendor WechatOpenSDK or AlipaySDK binaries. Link the official
native SDK artifacts in the host app or distribution package; PayKit detects
their standard Objective-C runtime classes and invokes the channel launch and
callback APIs through the adapter layer.

## Troubleshooting

- Missing request parameters return `PYKPayStatusFailed` with `rawCode`.
- Unavailable native SDK integration returns channel-specific failed results.
- If completion is not called after a channel app returns, verify URL
  Scheme/Universal Link forwarding reaches `PayKit.handleOpenURL` or
  `PayKit.handleUserActivity`.
- Do not call `WeChatPayAdapter`, `AlipayAdapter`, WechatOpenSDK or AlipaySDK
  directly from app code.
