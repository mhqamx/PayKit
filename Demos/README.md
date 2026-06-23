# PayKit Demos

The demo apps are complete CocoaPods host projects for customer integration
reference.

## Installed SDKs

Each demo integrates the in-repository PayKit SDK:

```ruby
pod 'PayKit', :path => '../..'
```

PayKit then brings in the official payment SDK dependencies declared by
`PayKit.podspec`:

```ruby
s.dependency 'WechatOpenSDK-XCFramework', '~> 2.0.5'
s.dependency 'AlipaySDK-iOS', '~> 15.8.30'
```

## Swift Demo

```sh
cd Demos/SwiftDemo
pod install
open SwiftDemo.xcworkspace
```

## Objective-C Demo

```sh
cd Demos/ObjCDemo
pod install
open ObjCDemo.xcworkspace
```

Open the `.xcworkspace`, not the `.xcodeproj`, after running CocoaPods.

If Xcode upgrades the project settings, keep `ENABLE_USER_SCRIPT_SANDBOXING`
set to `NO` on the demo app target. CocoaPods resource scripts need to write
inside the `Pods/` directory during device builds.
