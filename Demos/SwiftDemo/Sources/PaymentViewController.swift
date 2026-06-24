import PayKit
import UIKit

enum DemoConfig {
    static let wechatAppId = "wx-app-id"
    static let wechatUniversalLink = "https://example.com/app/"
    static let alipayScheme = "paykit-demo"

    // Channel payloads are demo defaults. In a real integration the app sends an
    // order to its backend and receives these channel-specific parameters.
    static let alipayOrderString = "app_id=demo&method=alipay.trade.app.pay&charset=utf-8&sign=demo"
    static let wechatPrepayId = "wx-prepay-id"
}

final class PaymentViewController: UIViewController, UITextFieldDelegate {
    private let scrollView = UIScrollView()
    private let amountField = UITextField()
    private let resultIndicator = UIView()
    private let resultTitle = UILabel()
    private let resultBody = UILabel()
    private let resultCard = DemoTheme.card()

    private var amountText: String {
        let raw = (amountField.text ?? "").trimmingCharacters(in: .whitespaces)
        let value = raw.isEmpty ? "0.01" : raw
        return "¥ \(value)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayKit"
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = DemoTheme.canvas
        configureNavigationBar()
        buildInterface()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = DemoTheme.canvas
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: DemoTheme.textPrimary,
            .font: DemoTheme.rounded(17, .bold)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }

    // MARK: Layout

    private func buildInterface() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        let pad = DemoTheme.pagePadding
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: pad),
            content.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -pad),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 8),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])

        content.addArrangedSubview(heroCard())
        content.addArrangedSubview(orderCard())
        content.addArrangedSubview(configureResultCard())

        let payButton = DemoTheme.primaryButton(title: "去支付")
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(presentPaymentSheet), for: .touchUpInside)
        content.addArrangedSubview(payButton)
        content.setCustomSpacing(22, after: resultCard)
        payButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
    }

    private func heroCard() -> UIView {
        let wordmark = UILabel()
        wordmark.text = "PayKit"
        wordmark.font = DemoTheme.rounded(26, .heavy)
        wordmark.textColor = DemoTheme.textPrimary

        let chip = PaddedLabel()
        chip.text = "DEMO"
        chip.font = DemoTheme.rounded(11, .bold)
        chip.textColor = DemoTheme.accent
        chip.backgroundColor = DemoTheme.accent.withAlphaComponent(0.14)
        chip.layer.cornerRadius = 7
        chip.layer.cornerCurve = .continuous
        chip.clipsToBounds = true
        chip.setContentHuggingPriority(.required, for: .horizontal)

        let topRow = UIStackView(arrangedSubviews: [wordmark, chip])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 10

        let subtitle = UILabel()
        subtitle.text = "客户接入参考收银台。SDK 只负责微信 / 支付宝调用、回调转发与结果归一，最终订单状态以业务后台为准。"
        subtitle.font = DemoTheme.text(13, .regular)
        subtitle.textColor = DemoTheme.textSecondary
        subtitle.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [topRow, subtitle])
        stack.axis = .vertical
        stack.spacing = 8
        return wrap(stack, in: DemoTheme.card())
    }

    private func orderCard() -> UIView {
        let label = UILabel()
        label.text = "订单金额"
        label.font = DemoTheme.text(13, .medium)
        label.textColor = DemoTheme.textSecondary

        let currency = UILabel()
        currency.text = "¥"
        currency.font = DemoTheme.rounded(34, .bold)
        currency.textColor = DemoTheme.textPrimary
        currency.setContentHuggingPriority(.required, for: .horizontal)

        amountField.text = "0.01"
        amountField.font = DemoTheme.rounded(40, .heavy)
        amountField.textColor = DemoTheme.textPrimary
        amountField.tintColor = DemoTheme.accent
        amountField.keyboardType = .decimalPad
        amountField.borderStyle = .none
        amountField.delegate = self
        amountField.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [.foregroundColor: DemoTheme.textTertiary]
        )

        let amountRow = UIStackView(arrangedSubviews: [currency, amountField])
        amountRow.axis = .horizontal
        amountRow.alignment = .firstBaseline
        amountRow.spacing = 6

        let divider = UIView()
        divider.backgroundColor = DemoTheme.cardBorder
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let note = UILabel()
        note.text = "订单号  PK202606240001 · 测试沙箱"
        note.font = DemoTheme.text(12, .regular)
        note.textColor = DemoTheme.textTertiary

        let stack = UIStackView(arrangedSubviews: [label, amountRow, divider, note])
        stack.axis = .vertical
        stack.spacing = 10
        stack.setCustomSpacing(16, after: amountRow)
        stack.setCustomSpacing(12, after: divider)
        return wrap(stack, in: DemoTheme.card())
    }

    private func configureResultCard() -> UIView {
        let header = UILabel()
        header.text = "支付结果"
        header.font = DemoTheme.text(13, .medium)
        header.textColor = DemoTheme.textSecondary

        resultIndicator.backgroundColor = DemoTheme.textTertiary
        resultIndicator.layer.cornerRadius = 4
        resultIndicator.translatesAutoresizingMaskIntoConstraints = false
        resultIndicator.widthAnchor.constraint(equalToConstant: 8).isActive = true
        resultIndicator.heightAnchor.constraint(equalToConstant: 8).isActive = true

        resultTitle.text = "等待支付"
        resultTitle.font = DemoTheme.rounded(18, .bold)
        resultTitle.textColor = DemoTheme.textPrimary

        let statusRow = UIStackView(arrangedSubviews: [resultIndicator, resultTitle])
        statusRow.axis = .horizontal
        statusRow.alignment = .center
        statusRow.spacing = 8

        resultBody.text = "点击「去支付」选择渠道后，回调结果会显示在这里。"
        resultBody.font = DemoTheme.text(13, .regular)
        resultBody.textColor = DemoTheme.textSecondary
        resultBody.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [header, statusRow, resultBody])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(10, after: header)
        return wrap(stack, in: resultCard)
    }

    private func wrap(_ content: UIView, in container: UIView) -> UIView {
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        return container
    }

    // MARK: Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func presentPaymentSheet() {
        view.endEditing(true)
        // SDK-owned standard payment sheet (Story 5.2). The SDK presents the
        // bottom sheet; once a channel is picked it asks us for the matching
        // request via the provider, then reuses the unified pay path.
        let configuration = PYKPaymentSheetConfiguration.standard(amountText: amountText)
        PayKit.presentPaymentSheet(
            from: self,
            configuration: configuration,
            requestProvider: { [weak self] channel, provide in
                guard let self = self else { return }
                self.showPending()
                // In a real app, fetch channel parameters from your backend here.
                provide(.success(self.demoRequest(for: channel)))
            },
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.show(result: result)
                }
            }
        )
    }

    private func demoRequest(for channel: PYKPayChannel) -> PYKPayRequest {
        switch channel {
        case .alipay:
            return PYKAlipayPayRequest(
                orderString: DemoConfig.alipayOrderString,
                appScheme: DemoConfig.alipayScheme
            )
        default:
            return PYKWechatPayRequest(
                appId: DemoConfig.wechatAppId,
                partnerId: "partner-id",
                prepayId: DemoConfig.wechatPrepayId,
                packageValue: "Sign=WXPay",
                nonceStr: "nonce-from-backend",
                timeStamp: "1700000000",
                sign: "sign-from-backend"
            )
        }
    }

    private func showPending() {
        resultIndicator.backgroundColor = DemoTheme.cancelled
        resultTitle.text = "支付进行中…"
        resultBody.text = "已通过 PayKit 拉起渠道客户端，等待回调。"
    }

    private func show(result: PYKPayResult) {
        let color: UIColor
        let statusText: String
        switch result.status {
        case .success:
            color = DemoTheme.success
            statusText = "支付成功"
        case .cancelled:
            color = DemoTheme.cancelled
            statusText = "已取消"
        case .failed:
            color = DemoTheme.failure
            statusText = "支付失败"
        @unknown default:
            color = DemoTheme.textTertiary
            statusText = "未知状态"
        }
        resultIndicator.backgroundColor = color
        resultTitle.text = statusText
        resultBody.text = [
            "渠道：\(channelName(result.channel))",
            "原始码：\(result.rawCode ?? "-")",
            "原始信息：\(result.rawMessage ?? "-")",
            "说明：客户端成功不等于订单最终成功，请以业务后台确认为准。"
        ].joined(separator: "\n")
    }

    private func channelName(_ channel: PYKPayChannel) -> String {
        switch channel {
        case .wechat:
            return "微信支付"
        case .alipay:
            return "支付宝"
        case .mock:
            return "模拟通道"
        default:
            return "未知通道"
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

/// Label with internal padding, used for the inline "DEMO" chip.
private final class PaddedLabel: UILabel {
    private let insets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
