import PayKit
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let wechat = PYKWechatConfig(appId: DemoConfig.wechatAppId, universalLink: DemoConfig.wechatUniversalLink)
        let alipay = PYKAlipayConfig(appScheme: DemoConfig.alipayScheme)
        PayKit.setup(wechat: wechat, alipay: alipay)
        return true
    }

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
}
