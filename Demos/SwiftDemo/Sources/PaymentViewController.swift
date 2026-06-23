import PayKit
import UIKit

enum DemoConfig {
    static let wechatAppId = "wx-app-id"
    static let wechatUniversalLink = "https://example.com/app/"
    static let alipayScheme = "paykit-demo"
}

final class PaymentViewController: UIViewController, UITextViewDelegate {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let alipayOrderInput = UITextView()
    private let wechatPrepayInput = UITextView()
    private let resultView = UITextView()
    private var alipayHeightConstraint: NSLayoutConstraint?
    private var wechatHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayKit 集成示例"
        view.backgroundColor = .systemGroupedBackground
        buildInterface()
        updateInputHeights()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateInputHeights()
    }

    private func buildInterface() {
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 18),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        contentStack.addArrangedSubview(headerView())
        contentStack.addArrangedSubview(inputSection(
            title: "支付宝支付",
            detail: "填写后端返回的完整 orderString，Demo 会通过 PayKit 调用支付宝 SDK。",
            inputTitle: "orderString",
            input: alipayOrderInput,
            buttonTitle: "发起支付宝支付",
            action: #selector(startAlipay)
        ))
        contentStack.addArrangedSubview(inputSection(
            title: "微信支付",
            detail: "当前示例保留 prepayId 输入，其余微信字段使用 Demo 默认值，实际接入时应全部来自后端。",
            inputTitle: "prepayId",
            input: wechatPrepayInput,
            buttonTitle: "发起微信支付",
            action: #selector(startWeChatPay)
        ))
        contentStack.addArrangedSubview(resultSection())

        configureInput(
            alipayOrderInput,
            text: "app_id=demo&method=alipay.trade.app.pay&charset=utf-8&sign=demo",
            accessibilityLabel: "支付宝订单字符串"
        )
        configureInput(
            wechatPrepayInput,
            text: "wx-prepay-id",
            accessibilityLabel: "微信预支付订单号"
        )
    }

    private func headerView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = "PayKit 支付 SDK Demo"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.text = "这是客户接入参考页面，不是 SDK 内置收银台。PayKit SDK 只负责微信/支付宝支付调用、回调转发和结果归一。"
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return card(stack)
    }

    private func inputSection(
        title: String,
        detail: String,
        inputTitle: String,
        input: UITextView,
        buttonTitle: String,
        action: Selector
    ) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = .preferredFont(forTextStyle: .footnote)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.adjustsFontForContentSizeCategory = true

        let fieldLabel = UILabel()
        fieldLabel.text = inputTitle
        fieldLabel.font = .preferredFont(forTextStyle: .subheadline)
        fieldLabel.textColor = .secondaryLabel
        fieldLabel.adjustsFontForContentSizeCategory = true

        let button = UIButton(type: .system)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        var configuration = UIButton.Configuration.filled()
        configuration.title = buttonTitle
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
        button.addTarget(self, action: action, for: .touchUpInside)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(detailLabel)
        stack.addArrangedSubview(fieldLabel)
        stack.addArrangedSubview(input)
        stack.addArrangedSubview(button)

        return card(stack)
    }

    private func resultSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        let titleLabel = UILabel()
        titleLabel.text = "支付结果"
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        resultView.isEditable = false
        resultView.isScrollEnabled = false
        resultView.font = .preferredFont(forTextStyle: .body)
        resultView.textColor = .label
        resultView.backgroundColor = .tertiarySystemGroupedBackground
        resultView.layer.cornerRadius = 8
        resultView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        resultView.text = "支付回调结果会显示在这里。客户端 success 只代表渠道客户端流程成功，最终订单状态仍需以业务后台确认为准。"
        resultView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(resultView)
        return card(stack)
    }

    private func card(_ content: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }

    private func configureInput(_ input: UITextView, text: String, accessibilityLabel: String) {
        input.text = text
        input.font = .preferredFont(forTextStyle: .body)
        input.adjustsFontForContentSizeCategory = true
        input.backgroundColor = .tertiarySystemGroupedBackground
        input.textColor = .label
        input.layer.cornerRadius = 8
        input.layer.borderWidth = 1
        input.layer.borderColor = UIColor.separator.cgColor
        input.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        input.autocapitalizationType = .none
        input.autocorrectionType = .no
        input.isScrollEnabled = false
        input.delegate = self
        input.accessibilityLabel = accessibilityLabel

        let height = input.heightAnchor.constraint(equalToConstant: 52)
        height.priority = .required
        height.isActive = true
        if input === alipayOrderInput {
            alipayHeightConstraint = height
        } else if input === wechatPrepayInput {
            wechatHeightConstraint = height
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        updateHeight(for: textView)
    }

    private func updateInputHeights() {
        updateHeight(for: alipayOrderInput)
        updateHeight(for: wechatPrepayInput)
    }

    private func updateHeight(for textView: UITextView) {
        let width = max(textView.bounds.width, view.bounds.width - 64)
        let targetSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let fittingHeight = textView.sizeThatFits(targetSize).height
        let newHeight = min(max(fittingHeight, 52), 180)
        textView.isScrollEnabled = fittingHeight > 180
        if textView === alipayOrderInput {
            alipayHeightConstraint?.constant = newHeight
        } else if textView === wechatPrepayInput {
            wechatHeightConstraint?.constant = newHeight
        }
    }

    @objc private func startAlipay() {
        let request = PYKAlipayPayRequest(
            orderString: alipayOrderInput.text ?? "",
            appScheme: DemoConfig.alipayScheme
        )
        PayKit.pay(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.show(result: result)
            }
        }
    }

    @objc private func startWeChatPay() {
        let request = PYKWechatPayRequest(
            appId: DemoConfig.wechatAppId,
            partnerId: "partner-id",
            prepayId: wechatPrepayInput.text ?? "",
            packageValue: "Sign=WXPay",
            nonceStr: "nonce-from-backend",
            timeStamp: "1700000000",
            sign: "sign-from-backend"
        )
        PayKit.pay(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.show(result: result)
            }
        }
    }

    private func show(result: PYKPayResult) {
        let status: String
        switch result.status {
        case .success:
            status = "成功"
        case .cancelled:
            status = "已取消"
        case .failed:
            status = "失败"
        @unknown default:
            status = "未知"
        }
        resultView.text = [
            "状态：\(status)",
            "渠道：\(channelName(result.channel))",
            "原始码：\(result.rawCode ?? "-")",
            "原始信息：\(result.rawMessage ?? "-")",
            "说明：客户端成功不等于订单最终成功，请以业务后台确认结果为准。"
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
}
