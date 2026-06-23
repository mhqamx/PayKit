import PayKit
import UIKit

enum DemoConfig {
    static let wechatAppId = "wx-app-id"
    static let wechatUniversalLink = "https://example.com/app/"
    static let alipayScheme = "paykit-demo"
}

final class PaymentViewController: UIViewController {
    private let alipayOrderField = UITextField()
    private let wechatPrepayField = UITextField()
    private let resultView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PayKit Swift Demo"
        view.backgroundColor = .systemBackground
        buildInterface()
    }

    private func buildInterface() {
        let titleLabel = UILabel()
        titleLabel.text = "PayKit client payment demo"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true

        let noteLabel = UILabel()
        noteLabel.text = "Replace the sample payloads with backend-issued WeChat and Alipay payment parameters."
        noteLabel.font = .preferredFont(forTextStyle: .footnote)
        noteLabel.textColor = .secondaryLabel
        noteLabel.numberOfLines = 0

        configureTextField(alipayOrderField, placeholder: "Alipay order string")
        alipayOrderField.text = "app_id=demo&method=alipay.trade.app.pay&charset=utf-8&sign=demo"

        configureTextField(wechatPrepayField, placeholder: "WeChat prepay id")
        wechatPrepayField.text = "wx-prepay-id"

        let alipayButton = UIButton(type: .system)
        alipayButton.setTitle("Start Alipay", for: .normal)
        alipayButton.addTarget(self, action: #selector(startAlipay), for: .touchUpInside)

        let wechatButton = UIButton(type: .system)
        wechatButton.setTitle("Start WeChat Pay", for: .normal)
        wechatButton.addTarget(self, action: #selector(startWeChatPay), for: .touchUpInside)

        resultView.isEditable = false
        resultView.font = .preferredFont(forTextStyle: .body)
        resultView.backgroundColor = .secondarySystemBackground
        resultView.layer.cornerRadius = 8
        resultView.text = "Payment result will appear here."

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            noteLabel,
            labeled("Alipay orderString", alipayOrderField),
            alipayButton,
            labeled("WeChat prepayId", wechatPrepayField),
            wechatButton,
            resultView
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            resultView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }

    private func labeled(_ label: String, _ control: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .preferredFont(forTextStyle: .subheadline)
        labelView.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [labelView, control])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    @objc private func startAlipay() {
        let request = PYKAlipayPayRequest(
            orderString: alipayOrderField.text ?? "",
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
            prepayId: wechatPrepayField.text ?? "",
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
            status = "success"
        case .cancelled:
            status = "cancelled"
        case .failed:
            status = "failed"
        @unknown default:
            status = "unknown"
        }
        resultView.text = [
            "status: \(status)",
            "channel: \(result.channel.rawValue)",
            "rawCode: \(result.rawCode ?? "-")",
            "rawMessage: \(result.rawMessage ?? "-")",
            "Client success still needs backend order confirmation."
        ].joined(separator: "\n")
    }
}
