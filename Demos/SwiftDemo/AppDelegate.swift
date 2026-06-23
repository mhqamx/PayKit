import UIKit
import PayKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let wechat = PYKWechatConfig(appId: "wx-app-id", universalLink: "https://example.com/app/")
        let alipay = PYKAlipayConfig(appScheme: "paykit-demo")
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

    func startAlipay(orderString: String) {
        let request = PYKAlipayPayRequest(orderString: orderString, appScheme: "paykit-demo")
        PayKit.pay(request: request) { result in
            switch result.status {
            case .success:
                print("Client flow succeeded; confirm final order state with backend.")
            case .cancelled:
                print("User cancelled.")
            case .failed:
                print("Failed: \(result.rawCode ?? "") \(result.rawMessage ?? "")")
            @unknown default:
                print("Unknown result.")
            }
        }
    }
}
