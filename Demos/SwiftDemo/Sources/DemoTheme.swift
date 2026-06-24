import UIKit

/// Centralized visual language for the demo. The demo locks to a custom dark
/// "premium fintech" palette so the look is intentional rather than inheriting
/// system grouped-table chrome.
enum DemoTheme {
    // MARK: Palette

    static let canvas = UIColor(hex: 0x0A0C10)
    static let card = UIColor(hex: 0x14171F)
    static let cardElevated = UIColor(hex: 0x1B1F29)
    static let cardBorder = UIColor(hex: 0x252A36)
    static let field = UIColor(hex: 0x0E1117)

    static let textPrimary = UIColor(hex: 0xF3F5FA)
    static let textSecondary = UIColor(hex: 0x8B93A7)
    static let textTertiary = UIColor(hex: 0x5C6378)

    /// Brand accent / primary CTA. Distinct from both channel colors so the
    /// "去支付" action never reads as a specific channel.
    static let accent = UIColor(hex: 0xFF5C39)
    static let accentInk = UIColor.white

    static let wechat = UIColor(hex: 0x07C160)
    static let alipay = UIColor(hex: 0x1677FF)

    static let success = UIColor(hex: 0x2BD576)
    static let failure = UIColor(hex: 0xFF5C5C)
    static let cancelled = UIColor(hex: 0xFFB23E)

    // MARK: Metrics

    static let cardRadius: CGFloat = 18
    static let controlRadius: CGFloat = 14
    static let pagePadding: CGFloat = 18

    // MARK: Fonts

    /// Rounded SF for numerals and the wordmark — friendlier, more premium than
    /// the default cut, and the most distinctive typographic move available
    /// without bundling a custom face.
    static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: size)
    }

    static func text(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }

    // MARK: Builders

    static func card(cornerRadius: CGFloat = cardRadius) -> UIView {
        let view = UIView()
        view.backgroundColor = card
        view.layer.cornerRadius = cornerRadius
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.layer.borderColor = cardBorder.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func primaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = accent
        configuration.baseForegroundColor = accentInk
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 17, leading: 16, bottom: 17, trailing: 16)
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: rounded(17, .semibold)])
        )
        button.configuration = configuration
        button.layer.cornerCurve = .continuous
        // Subtle press feedback.
        button.configurationUpdateHandler = { button in
            button.alpha = button.isHighlighted ? 0.85 : 1
            button.transform = button.isHighlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
        }
        return button
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
