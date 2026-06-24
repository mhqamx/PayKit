#if canImport(UIKit)
import UIKit

/// Internal bottom payment sheet rendered by the SDK. Driven entirely by a
/// `PYKPaymentSheetConfiguration`; reports the confirmed channel or a cancel
/// back to the coordinator. Merchants never instantiate this directly — they
/// call `PayKit.presentPaymentSheet` / `PYKPayKit presentPaymentSheet...`.
final class PYKPaymentSheetViewController: UIViewController {
    private let configuration: PYKPaymentSheetConfiguration
    private let onConfirm: (PYKPayChannel) -> Void
    private let onCancel: () -> Void

    private let dimView = UIView()
    private let panel = UIView()
    private var panelBottom: NSLayoutConstraint?

    private var didFinish = false
    private var selected: PYKPayChannel
    private var rows: [PYKPayChannel: PYKChannelRow] = [:]

    init(
        configuration: PYKPaymentSheetConfiguration,
        onConfirm: @escaping (PYKPayChannel) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.selected = configuration.options.first { $0.isEnabled }?.channel
            ?? configuration.options.first?.channel
            ?? .unknown
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        overrideUserInterfaceStyle = .dark
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildBackdrop()
        buildPanel()
        select(selected, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentPanel()
    }

    // MARK: Build

    private func buildBackdrop() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
    }

    private func buildPanel() {
        panel.backgroundColor = PYKSheetStyle.panel
        panel.layer.cornerRadius = 28
        panel.layer.cornerCurve = .continuous
        panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)

        let bottom = panel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 600)
        panelBottom = bottom
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom
        ])

        let grabber = UIView()
        grabber.backgroundColor = PYKSheetStyle.border
        grabber.layer.cornerRadius = 2.5
        grabber.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = configuration.title
        title.font = PYKSheetStyle.rounded(20, .bold)
        title.textColor = PYKSheetStyle.textPrimary

        let titleRow = UIStackView(arrangedSubviews: [title])
        titleRow.axis = .horizontal
        titleRow.alignment = .firstBaseline
        if let amount = configuration.amountText {
            let amountTag = UILabel()
            amountTag.text = amount
            amountTag.font = PYKSheetStyle.rounded(20, .bold)
            amountTag.textColor = PYKSheetStyle.accent
            amountTag.setContentHuggingPriority(.required, for: .horizontal)
            titleRow.addArrangedSubview(amountTag)
        }

        let stack = UIStackView(arrangedSubviews: [titleRow])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(20, after: titleRow)
        stack.translatesAutoresizingMaskIntoConstraints = false

        for option in configuration.options {
            let row = PYKChannelRow(option: option)
            rows[option.channel] = row
            row.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(row)
            stack.setCustomSpacing(10, after: row)
        }

        let confirm = PYKSheetStyle.primaryButton(title: configuration.confirmTitle)
        confirm.translatesAutoresizingMaskIntoConstraints = false
        confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        if let last = configuration.options.last, let lastRow = rows[last.channel] {
            stack.setCustomSpacing(22, after: lastRow)
        }
        stack.addArrangedSubview(confirm)

        if let footnote = configuration.footnote {
            let label = UILabel()
            label.text = footnote
            label.font = PYKSheetStyle.text(12, .regular)
            label.textColor = PYKSheetStyle.textTertiary
            label.numberOfLines = 0
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }

        panel.addSubview(grabber)
        panel.addSubview(stack)

        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: panel.topAnchor, constant: 10),
            grabber.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 40),
            grabber.heightAnchor.constraint(equalToConstant: 5),

            stack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            confirm.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])

        panel.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }

    // MARK: Animation

    private func presentPanel() {
        view.layoutIfNeeded()
        panelBottom?.constant = 0
        UIView.animate(
            withDuration: 0.55, delay: 0,
            usingSpringWithDamping: 0.86, initialSpringVelocity: 0.4,
            options: [.curveEaseOut]
        ) {
            self.dimView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func dismissPanel(then action: @escaping () -> Void) {
        panelBottom?.constant = panel.bounds.height + view.safeAreaInsets.bottom + 40
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn]) {
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: action)
        }
    }

    // MARK: Actions

    @objc private func cancelTapped() {
        finish { self.onCancel() }
    }

    @objc private func confirmTapped() {
        let channel = selected
        finish { self.onConfirm(channel) }
    }

    /// Guarantees exactly one terminal callback even if cancel and confirm race.
    private func finish(_ action: @escaping () -> Void) {
        guard !didFinish else { return }
        didFinish = true
        dismissPanel(then: action)
    }

    @objc private func rowTapped(_ row: PYKChannelRow) {
        guard row.option.isEnabled else { return }
        select(row.option.channel, animated: true)
    }

    private func select(_ channel: PYKPayChannel, animated: Bool) {
        selected = channel
        let apply = {
            for (key, row) in self.rows {
                row.setSelected(key == channel)
            }
        }
        if animated {
            UIView.animate(withDuration: 0.2) { apply() }
            UISelectionFeedbackGenerator().selectionChanged()
        } else {
            apply()
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).y
        switch gesture.state {
        case .changed:
            panelBottom?.constant = max(0, translation)
            dimView.alpha = 1 - min(translation / 320, 0.6)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view).y
            if translation > 120 || velocity > 900 {
                cancelTapped()
            } else {
                presentPanel()
            }
        default:
            break
        }
    }
}

/// A selectable channel row: colored badge, title/subtitle and an animated
/// selection ring.
final class PYKChannelRow: UIControl {
    let option: PYKPaymentOption
    private let radioOuter = UIView()
    private let radioInner = UIView()

    init(option: PYKPaymentOption) {
        self.option = option
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = PYKSheetStyle.field
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        layer.borderWidth = 1.5
        layer.borderColor = PYKSheetStyle.border.cgColor
        isEnabled = option.isEnabled
        alpha = option.isEnabled ? 1 : 0.45

        let badge = UILabel()
        badge.text = PYKSheetStyle.badgeText(for: option)
        badge.font = PYKSheetStyle.rounded(18, .bold)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.backgroundColor = PYKSheetStyle.badgeColor(for: option.channel)
        badge.layer.cornerRadius = 11
        badge.layer.cornerCurve = .continuous
        badge.clipsToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = option.title
        titleLabel.font = PYKSheetStyle.text(16, .semibold)
        titleLabel.textColor = PYKSheetStyle.textPrimary

        let textStack = UIStackView(arrangedSubviews: [titleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        if let subtitle = option.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = PYKSheetStyle.text(12, .regular)
            subtitleLabel.textColor = PYKSheetStyle.textSecondary
            textStack.addArrangedSubview(subtitleLabel)
        }

        radioOuter.layer.cornerRadius = 11
        radioOuter.layer.borderWidth = 2
        radioOuter.layer.borderColor = PYKSheetStyle.border.cgColor
        radioOuter.translatesAutoresizingMaskIntoConstraints = false
        radioInner.backgroundColor = PYKSheetStyle.accent
        radioInner.layer.cornerRadius = 6
        radioInner.alpha = 0
        radioInner.translatesAutoresizingMaskIntoConstraints = false
        radioOuter.addSubview(radioInner)

        let content = UIStackView(arrangedSubviews: [badge, textStack, radioOuter])
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = 14
        content.isUserInteractionEnabled = false
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 64),
            badge.widthAnchor.constraint(equalToConstant: 38),
            badge.heightAnchor.constraint(equalToConstant: 38),
            radioOuter.widthAnchor.constraint(equalToConstant: 22),
            radioOuter.heightAnchor.constraint(equalToConstant: 22),
            radioInner.centerXAnchor.constraint(equalTo: radioOuter.centerXAnchor),
            radioInner.centerYAnchor.constraint(equalTo: radioOuter.centerYAnchor),
            radioInner.widthAnchor.constraint(equalToConstant: 12),
            radioInner.heightAnchor.constraint(equalToConstant: 12),
            content.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -13),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet { if option.isEnabled { alpha = isHighlighted ? 0.7 : 1 } }
    }

    func setSelected(_ isSelected: Bool) {
        layer.borderColor = (isSelected ? PYKSheetStyle.accent : PYKSheetStyle.border).cgColor
        radioOuter.layer.borderColor = (isSelected ? PYKSheetStyle.accent : PYKSheetStyle.border).cgColor
        radioInner.alpha = isSelected ? 1 : 0
        radioInner.transform = isSelected ? .identity : CGAffineTransform(scaleX: 0.3, y: 0.3)
    }
}

/// Self-contained visual language for the SDK sheet (no dependency on host app
/// theming).
enum PYKSheetStyle {
    static let panel = color(0x1B1F29)
    static let field = color(0x0E1117)
    static let border = color(0x252A36)
    static let textPrimary = color(0xF3F5FA)
    static let textSecondary = color(0x8B93A7)
    static let textTertiary = color(0x5C6378)
    static let accent = color(0xFF5C39)

    static func color(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    static func rounded(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }

    static func text(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }

    static func badgeColor(for channel: PYKPayChannel) -> UIColor {
        switch channel {
        case .wechat: return color(0x07C160)
        case .alipay: return color(0x1677FF)
        default: return color(0x5C6378)
        }
    }

    static func badgeText(for option: PYKPaymentOption) -> String {
        switch option.channel {
        case .wechat: return "微"
        case .alipay: return "支"
        default: return String(option.title.prefix(1))
        }
    }

    static func primaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = accent
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 17, leading: 16, bottom: 17, trailing: 16)
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: rounded(17, .semibold)])
        )
        button.configuration = configuration
        button.layer.cornerCurve = .continuous
        button.configurationUpdateHandler = { button in
            button.alpha = button.isHighlighted ? 0.85 : 1
            button.transform = button.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
        return button
    }
}
#endif
