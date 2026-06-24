# PayKit

PayKit is an iOS 15+ payment SDK that wraps WeChat Pay and Alipay client
payment flows behind one Swift and Objective-C public API.

The SDK only handles client-side launch, callback routing and result
normalization. A `success` result means the payment channel returned client-flow
success. The merchant app must still confirm the final order status with its
own backend.

`PYKPayKit` is the single entry point for both Swift and Objective-C. (There is
no `PayKit` Swift facade: a public type named `PayKit` collides with the module
name and breaks the binary-framework interface.)

## Swift

```swift
let wechat = PYKWechatConfig(appId: "wx-app-id", universalLink: "https://example.com/app/")
let alipay = PYKAlipayConfig(appScheme: "paykit-demo")

PYKPayKit.setup(wechat: wechat, alipay: alipay)

let request = PYKAlipayPayRequest(orderString: orderStringFromBackend, appScheme: "paykit-demo")
PYKPayKit.pay(request: request) { result in
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
    PYKPayKit.handleOpenURL(url)
}

func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
) -> Bool {
    PYKPayKit.handleUserActivity(userActivity)
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

The repository includes complete CocoaPods-based iOS demo projects. Each demo
integrates the in-repository PayKit SDK and PayKit brings in the official
payment SDK pods:

```ruby
pod 'PayKit', :path => '../..'
# PayKit.podspec depends on:
# - WechatOpenSDK-XCFramework
# - AlipaySDK-iOS
```

Run CocoaPods and open the workspace:

```sh
cd Demos/SwiftDemo && pod install && open SwiftDemo.xcworkspace
cd Demos/ObjCDemo && pod install && open ObjCDemo.xcworkspace
```

Both demos include:

- app startup configuration for WeChat and Alipay
- URL Scheme and Universal Link forwarding
- WeChat typed request creation
- Alipay typed request creation
- unified result display

Build checks:

```sh
xcodebuild -workspace Demos/SwiftDemo/SwiftDemo.xcworkspace -scheme SwiftDemo -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
xcodebuild -workspace Demos/ObjCDemo/ObjCDemo.xcworkspace -scheme ObjCDemo -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

## Distribution

PayKit ships as a precompiled **binary XCFramework**, so the implementation is
not exposed as source to integrating apps — only the public `PYK` API
(`.swiftinterface` + generated Objective-C header) is visible. `PayKit.podspec`
vendors `Distribution/Build/PayKit.xcframework`.

```ruby
pod 'PayKit', :git => 'https://github.com/mhqamx/PayKit.git', :tag => '0.3.0'
```

Build check (source tree, for development):

```sh
swift test
```

Release process — rebuild the binary before tagging:

```sh
xcodegen generate --spec project-framework.yml
PAYKIT_XCODE_PROJECT=PayKit.xcodeproj PAYKIT_SCHEME=PayKit Distribution/build-xcframework.sh
# commit Distribution/Build/PayKit.xcframework, bump PayKit.podspec, then tag
```

The repository keeps the Swift source for development and for building the
framework; the published pod vendors only the binary, so consumers receive no
`.swift` sources.

PayKit does not vendor WechatOpenSDK or AlipaySDK binaries. Link the official
native SDK artifacts in the host app or distribution package; PayKit detects
their standard Objective-C runtime classes and invokes the channel launch and
callback APIs through the adapter layer.

## Troubleshooting

- Missing request parameters return `PYKPayStatusFailed` with `rawCode`.
- Unavailable native SDK integration returns channel-specific failed results.
- If completion is not called after a channel app returns, verify URL
  Scheme/Universal Link forwarding reaches `PYKPayKit.handleOpenURL` or
  `PYKPayKit.handleUserActivity`.
- If device builds fail in a CocoaPods `[CP]` script with a sandbox denial,
  set `ENABLE_USER_SCRIPT_SANDBOXING=NO` on the app target.
- Do not call `WeChatPayAdapter`, `AlipayAdapter`, WechatOpenSDK or AlipaySDK
  directly from app code.
