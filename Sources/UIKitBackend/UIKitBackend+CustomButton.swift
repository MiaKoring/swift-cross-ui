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
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? .borderless {
            case .plain, .borderless: SIMD2(0, 0)
            case .bordered: SIMD2(Int(UICustomButton.horizontalPadding * 2), Int(UICustomButton.verticalPadding * 2))
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
    
    public override var isHighlighted: Bool {
        didSet {
            buttonStyle.handleHighlight(self)
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            self.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
        
        if #available(iOS 15.0, *) {
            button.configuration = UIButton.Configuration.bordered()
        } else {
            button.layer.backgroundColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 8
        }
    
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    @objc private func handleTap() {
        action?()
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
}

extension ButtonStyle {
    fileprivate func updateBackground(_ button: UICustomButton) {
        guard #available(iOS 15.0, *) else { return }
        var hideButton = false
        
        switch self {
            case .bordered:
                button.button.configuration = .bordered()
            case .plain, .borderless:
                hideButton = true
        }
        
        button.button.isHidden = hideButton
    }
    
    fileprivate func handleHighlight(_ button: UICustomButton) {
        switch self {
            case .bordered:
                button.button.isHighlighted = button.isHighlighted
            case .plain, .borderless:
                button.alpha = button.isHighlighted ? 0.75 : 1.0
        }
    }
}
