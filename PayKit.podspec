Pod::Spec.new do |s|
  s.name = 'PayKit'
  s.version = '0.3.0'
  s.summary = 'iOS client payment SDK for WeChat Pay and Alipay.'
  s.description = 'PayKit wraps WeChat Pay and Alipay client launch, callback routing and result normalization.'
  s.homepage = 'https://github.com/mhqamx/PayKit'
  s.license = { :type => 'MIT' }
  s.author = { 'mhqamx' => 'supermax932016@gmail.com' }
  s.source = { :git => 'https://github.com/mhqamx/PayKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9']
  # Binary distribution: ship the precompiled XCFramework so the implementation
  # is not exposed as source. Build it with Distribution/build-xcframework.sh
  # before tagging a release. Channel icons are embedded inside the framework.
  s.vendored_frameworks = 'Distribution/Build/PayKit.xcframework'
  s.dependency 'WechatOpenSDK-XCFramework', '~> 2.0.5'
  s.dependency 'AlipaySDK-iOS', '~> 15.8.30'
end
