import Foundation

/// A single selectable payment channel shown in the SDK payment sheet.
///
/// Foundation-only and Objective-C visible so Swift, Objective-C and mixed apps
/// share one contract (AD-1). Carries presentation text only — never order,
/// pricing or backend state (AD-5).
@objcMembers
@objc(PYKPaymentOption)
public final class PYKPaymentOption: NSObject {
    public let channel: PYKPayChannel
    public let title: String
    public let subtitle: String?
    public let isEnabled: Bool

    public init(channel: PYKPayChannel, title: String, subtitle: String? = nil, isEnabled: Bool = true) {
        self.channel = channel
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        super.init()
    }

    public static func wechat(subtitle: String? = "亿万用户的选择，安全快速") -> PYKPaymentOption {
        PYKPaymentOption(channel: .wechat, title: "微信支付", subtitle: subtitle)
    }

    public static func alipay(subtitle: String? = "数亿用户都在用，真安全") -> PYKPaymentOption {
        PYKPaymentOption(channel: .alipay, title: "支付宝", subtitle: subtitle)
    }
}

/// Configuration for the SDK standard payment sheet. The sheet is a minimal
/// channel selector — not a full cashier — so this never models discounts,
/// item lists or order confirmation.
@objcMembers
@objc(PYKPaymentSheetConfiguration)
public final class PYKPaymentSheetConfiguration: NSObject {
    public let title: String
    /// Optional amount shown for context (e.g. "¥ 0.01"). Display only.
    public let amountText: String?
    public let options: [PYKPaymentOption]
    public let confirmTitle: String
    public let footnote: String?

    public init(
        title: String,
        amountText: String?,
        options: [PYKPaymentOption],
        confirmTitle: String,
        footnote: String?
    ) {
        self.title = title
        self.amountText = amountText
        self.options = options
        self.confirmTitle = confirmTitle
        self.footnote = footnote
        super.init()
    }

    /// Default Chinese configuration offering WeChat Pay and Alipay.
    @objc(standardConfigurationWithAmountText:)
    public static func standard(amountText: String? = nil) -> PYKPaymentSheetConfiguration {
        PYKPaymentSheetConfiguration(
            title: "选择支付方式",
            amountText: amountText,
            options: [.wechat(), .alipay()],
            confirmTitle: "确认支付",
            footnote: "客户端成功 ≠ 订单最终成功，请以业务后台确认为准。"
        )
    }
}
