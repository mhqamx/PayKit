#import "SceneDelegate.h"
#import "PaymentViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) {
        return;
    }
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    PaymentViewController *controller = [[PaymentViewController alloc] init];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [window makeKeyAndVisible];
    self.window = window;
}

@end
