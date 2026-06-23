#import "AppDelegate.h"
@import PayKit;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PYKWechatConfig *wechat = [[PYKWechatConfig alloc] initWithAppId:@"wx-app-id"
                                                       universalLink:@"https://example.com/app/"];
    PYKAlipayConfig *alipay = [[PYKAlipayConfig alloc] initWithAppScheme:@"paykit-demo"];
    [PYKPayKit setupWithWechat:wechat alipay:alipay];
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [PYKPayKit handleOpenURL:url];
}

- (void)startAlipayWithOrderString:(NSString *)orderString {
    PYKAlipayPayRequest *request = [[PYKAlipayPayRequest alloc] initWithOrderString:orderString
                                                                          appScheme:@"paykit-demo"];
    [PYKPayKit payWithRequest:request completion:^(PYKPayResult *result) {
        if (result.status == PYKPayStatusSuccess) {
            NSLog(@"Client flow succeeded; confirm final order state with backend.");
        } else if (result.status == PYKPayStatusCancelled) {
            NSLog(@"User cancelled.");
        } else {
            NSLog(@"Failed: %@ %@", result.rawCode, result.rawMessage);
        }
    }];
}

@end
