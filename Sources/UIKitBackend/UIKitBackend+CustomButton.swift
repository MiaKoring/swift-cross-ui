import UIKit
import SwiftCrossUI

extension UIKitBackend {
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = UICustomButton()
        let widget = widget as! UIView
        
        button.translatesAutoresizingMaskIntoConstraints = false
        widget.translatesAutoresizingMaskIntoConstraints = false
        widget.isUserInteractionEnabled = false
        
        button.addSubview(widget)
        button.setupConstraints()
        
        return CustomButtonWidget(button: button)
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = (button as! CustomButtonWidget).child
        button.action = action
        button.isEnabled = environment.isEnabled
        button.buttonStyle = environment.buttonStyle ?? .borderless
   
        // Automatically sets the label text of a Button("") {} as accessibilityLabel.
        // This should be improved via a future .accessibilityLabel(_:) modifier.
        // The ViewBuilder button init is not covered by this current solution.
        if let child = (button.subviews[1] as? WrapperWidget<TextView>)?.child {
            button.accessibilityLabel = child.text
        }
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        let borderedPadding = SIMD2(
            Int(UICustomButton.horizontalPadding * 2),
            Int(UICustomButton.verticalPadding * 2)
        )
        
        // tvOS always gets full padding, due to highlighting using
        // the highlighted state of bordered button for all styles.
        #if os(tvOS)
            return borderedPadding
        #endif
        
        return switch environment.buttonStyle ?? .borderless {
            case .plain, .borderless: SIMD2(0, 0)
            case .bordered: borderedPadding
        }
    }
    
    public func defaultButtonStyle() -> ButtonStyle {
        .borderless
    }
}

final class CustomButtonWidget: WrapperWidget<UICustomButton> {
    init(button: UICustomButton) {
        super.init(child: button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

final class UICustomButton: UIControl {
    var action: (() -> Void)?
    
    let button = UIButton(type: .system)
    
    var buttonStyle: ButtonStyle = .borderless {
        didSet {
            buttonStyle.updateBackground(self)
        }
    }
    
    static let horizontalPadding: CGFloat = 12
    static let verticalPadding: CGFloat = 6
    
    override public var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                options: [.allowUserInteraction],
                animations: { [weak self] in
                    guard let self else { return }
                    self.buttonStyle.handleHighlight(self)
                },
                completion: nil
            )
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    override public var canBecomeFocused: Bool { isEnabled }
    
    init() {
        super.init(frame: .zero)
        
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = [.button]
        
        addSubview(button)
        
        if #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) {
            button.configuration = UIButton.Configuration.bordered()
        }
        
        #if os(tvOS)
            addTarget(self, action: #selector(handleTap), for: .primaryActionTriggered)
        #else
            addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        #endif
    }
    
    @objc private func handleTap() {
        action?()
    }
    
    override public func accessibilityActivate() -> Bool {
        action?()
        return true
    }
    
    override public func didUpdateFocus(
        in _: UIFocusUpdateContext,
        with _: UIFocusAnimationCoordinator
    ) {
        buttonStyle.updateBackground(self)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setupConstraints() {
        guard
            subviews.count == 2
        else { return }
        let background = subviews[0]
        let child = subviews[1]
        
        NSLayoutConstraint.activate([
            background
                .leadingAnchor
                .constraint(
                    equalTo: leadingAnchor
                ),
            background
                .trailingAnchor
                .constraint(
                    equalTo: trailingAnchor
                ),
            background
                .topAnchor
                .constraint(
                    equalTo: topAnchor
                ),
            background
                .bottomAnchor
                .constraint(
                    equalTo: bottomAnchor
                ),
        ])
        
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    // The primary action triggered didn't work out of the box on tvOS
#if os(tvOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first?.type == .select else {
            super.pressesBegan(presses, with: event)
            return
        }
        isHighlighted = true
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first?.type == .select else {
            super.pressesEnded(presses, with: event)
            return
        }
        isHighlighted = false
        sendActions(for: .primaryActionTriggered)
    }
    
    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first?.type == .select else {
            super.pressesCancelled(presses, with: event)
            return
        }
        isHighlighted = false
    }
#endif
}

extension ButtonStyle {
    fileprivate func updateBackground(_ button: UICustomButton) {
        var hideButton = false
        defer { button.button.isHidden = hideButton }
        
        // We don't support bordered button style on older versions.
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            hideButton = true
            return
        }
        
        #if os(tvOS)
            guard !button.isFocused else {
                button.button.isHighlighted = true
                button.button.configuration = .bordered()
                return
            }
        #endif
        
        button.button.isHighlighted = false
        
        switch self {
            case .bordered:
                button.button.configuration = .bordered()
            case .plain, .borderless:
                hideButton = true
        }
    }
    
    fileprivate func handleHighlight(_ button: UICustomButton) {
        guard #available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *) else {
            button.alpha = button.isHighlighted ? 0.75 : 1.0
            return
        }
        switch self {
            case .bordered:
                button.button.isHighlighted = button.isHighlighted
            case .plain, .borderless:
                button.alpha = button.isHighlighted ? 0.75 : 1.0
        }
    }
}
