#import "AppDelegate.h"
#import "DemoConfig.h"
@import PayKit;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PYKWechatConfig *wechat = [[PYKWechatConfig alloc] initWithAppId:PayKitDemoWechatAppId
                                                       universalLink:PayKitDemoWechatUniversalLink];
    PYKAlipayConfig *alipay = [[PYKAlipayConfig alloc] initWithAppScheme:PayKitDemoAlipayScheme];
    [PYKPayKit setupWithWechat:wechat alipay:alipay];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [PYKPayKit handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [PYKPayKit handleUserActivity:userActivity];
}

@end
