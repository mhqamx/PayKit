Pod::Spec.new do |s|
  s.name = 'PayKit'
  s.version = '0.2.1'
  s.summary = 'iOS client payment SDK for WeChat Pay and Alipay.'
  s.description = 'PayKit wraps WeChat Pay and Alipay client launch, callback routing and result normalization.'
  s.homepage = 'https://github.com/mhqamx/PayKit'
  s.license = { :type => 'MIT' }
  s.author = { 'mhqamx' => 'supermax932016@gmail.com' }
  s.source = { :git => 'https://github.com/mhqamx/PayKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9']
  s.static_framework = true
  s.source_files = 'Sources/PayKit/**/*.{swift,h,m}'
  s.exclude_files = ['Tests/**/*', 'Demos/**/*']
  s.resource_bundles = { 'PayKit' => ['Sources/PayKit/Resources/*.png'] }
  s.dependency 'WechatOpenSDK-XCFramework', '~> 2.0.5'
  s.dependency 'AlipaySDK-iOS', '~> 15.8.30'
end
