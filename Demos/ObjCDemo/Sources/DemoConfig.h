#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const PayKitDemoWechatAppId;
FOUNDATION_EXPORT NSString * const PayKitDemoWechatUniversalLink;
FOUNDATION_EXPORT NSString * const PayKitDemoAlipayScheme;

// Channel payloads are demo defaults. In a real integration the app sends an
// order to its backend and receives these channel-specific parameters.
FOUNDATION_EXPORT NSString * const PayKitDemoAlipayOrderString;
FOUNDATION_EXPORT NSString * const PayKitDemoWechatPrepayId;

NS_ASSUME_NONNULL_END
