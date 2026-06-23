import Foundation

@objcMembers
@objc(PYKPayKit)
public final class PYKPayKit: NSObject {
    internal private(set) static var currentWechatConfig: PYKWechatConfig?
    internal private(set) static var currentAlipayConfig: PYKAlipayConfig?

    public override init() {
        super.init()
    }

    @objc(setupWithWechat:alipay:)
    public static func setup(wechat: PYKWechatConfig?, alipay: PYKAlipayConfig?) {
        currentWechatConfig = wechat
        currentAlipayConfig = alipay
        PayCallbackRouter.shared.register(WeChatPayAdapter(config: wechat))
        PayCallbackRouter.shared.register(AlipayAdapter(config: alipay))
    }

    @objc(payWithRequest:completion:)
    public static func pay(request: PYKPayRequest, completion: @escaping (PYKPayResult) -> Void) {
        if let validationFailure = (request as? PYKRequestValidating)?.validationFailureResult() {
            completion(validationFailure)
            return
        }
        PayCallbackRouter.shared.pay(request: request, completion: completion)
    }

    @objc(handleOpenURL:)
    public static func handleOpenURL(_ url: URL) -> Bool {
        PayCallbackRouter.shared.handleOpenURL(url)
    }

    @objc(handleUserActivity:)
    public static func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        PayCallbackRouter.shared.handleUserActivity(userActivity)
    }

    internal static func resetForTesting() {
        currentWechatConfig = nil
        currentAlipayConfig = nil
        PayCallbackRouter.shared.reset()
    }

    internal static func registerMockAdapterForTesting(result: PYKPayResult) {
        PayCallbackRouter.shared.register(MockPayAdapter(result: result))
    }

    internal static func setWeChatNativeClientForTesting(_ client: WeChatNativePaying) {
        PayCallbackRouter.shared.register(WeChatPayAdapter(config: currentWechatConfig, nativeClient: client))
    }

    internal static func setAlipayNativeClientForTesting(_ client: AlipayNativePaying) {
        PayCallbackRouter.shared.register(AlipayAdapter(config: currentAlipayConfig, nativeClient: client))
    }
}
