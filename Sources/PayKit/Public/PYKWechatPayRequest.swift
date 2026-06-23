import Foundation

@objcMembers
@objc(PYKWechatPayRequest)
public final class PYKWechatPayRequest: PYKPayRequest, PYKRequestValidating {
    public let appId: String
    public let partnerId: String
    public let prepayId: String
    public let packageValue: String
    public let nonceStr: String
    public let timeStamp: String
    public let sign: String

    public init(
        appId: String,
        partnerId: String,
        prepayId: String,
        packageValue: String,
        nonceStr: String,
        timeStamp: String,
        sign: String
    ) {
        self.appId = appId
        self.partnerId = partnerId
        self.prepayId = prepayId
        self.packageValue = packageValue
        self.nonceStr = nonceStr
        self.timeStamp = timeStamp
        self.sign = sign
        super.init(channel: .wechat)
    }

    func validationFailureResult() -> PYKPayResult? {
        let fields = [
            ("appId", appId),
            ("partnerId", partnerId),
            ("prepayId", prepayId),
            ("packageValue", packageValue),
            ("nonceStr", nonceStr),
            ("timeStamp", timeStamp),
            ("sign", sign)
        ]
        return fields.first { $0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { field in
                PYKPayResult.failure(
                    channel: .wechat,
                    code: "validation_failed",
                    message: "Missing required WeChat field: \(field.0)",
                    rawCode: "paykit_validation_failed"
                )
            }
    }
}
