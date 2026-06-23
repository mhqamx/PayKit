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
    }

    @objc(payWithRequest:completion:)
    public static func pay(request: PYKPayRequest, completion: @escaping (PYKPayResult) -> Void) {
        let error = PYKPayError(
            code: "channel_unavailable",
            message: "No payment adapter is available for the requested channel."
        )
        let result = PYKPayResult(
            status: .failed,
            channel: request.channel,
            error: error,
            rawCode: "paykit_channel_unavailable",
            rawMessage: error.message
        )
        completion(result)
    }

    internal static func resetForTesting() {
        currentWechatConfig = nil
        currentAlipayConfig = nil
    }
}
