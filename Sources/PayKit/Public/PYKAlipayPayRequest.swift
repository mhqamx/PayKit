import Foundation

@objcMembers
@objc(PYKAlipayPayRequest)
public final class PYKAlipayPayRequest: PYKPayRequest, PYKRequestValidating {
    public let orderString: String
    public let appScheme: String

    public init(orderString: String, appScheme: String) {
        self.orderString = orderString
        self.appScheme = appScheme
        super.init(channel: .alipay)
    }

    func validationFailureResult() -> PYKPayResult? {
        if orderString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return PYKPayResult.failure(
                channel: .alipay,
                code: "validation_failed",
                message: "Missing required Alipay field: orderString",
                rawCode: "paykit_validation_failed"
            )
        }
        if appScheme.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return PYKPayResult.failure(
                channel: .alipay,
                code: "validation_failed",
                message: "Missing required Alipay field: appScheme",
                rawCode: "paykit_validation_failed"
            )
        }
        return nil
    }
}
