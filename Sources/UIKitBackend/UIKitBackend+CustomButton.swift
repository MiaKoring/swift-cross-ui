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
        SIMD2(Int(UICustomButton.horizontalPadding * 2), Int(UICustomButton.verticalPadding * 2))
    }
}

final class CustomButtonWidget: WrapperWidget<UICustomButton> {
    init(button: UICustomButton) {
        super.init(child: button)
        
        let constraints = [
            button
                .leadingAnchor
                .constraint(
                    equalTo: leadingAnchor
                ),
            button
                .trailingAnchor
                .constraint(
                    equalTo: trailingAnchor
                ),
            button
                .topAnchor
                .constraint(
                    equalTo: topAnchor
                ),
            button
                .bottomAnchor
                .constraint(
                    equalTo: bottomAnchor
                ),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

final class UICustomButton: UIControl {
    var action: (() -> Void)?
    
    let button = UIButton(type: .system)
    
    var buttonStyle: ButtonStyle = .borderless {
        didSet {
            buttonStyle.setConstraints(self)
            buttonStyle.updateBackground(self)
        }
    }
    
    static let horizontalPadding: CGFloat = 11
    static let verticalPadding: CGFloat = 4
    
    fileprivate var attachedConstraints = [NSLayoutConstraint]()
    
    public override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.75 : 1.0
        }
    }
    
    public override var isEnabled: Bool {
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
            subviews.count == 2,
            attachedConstraints.isEmpty
        else { return }
        let background = subviews[0]
        let child = subviews[1]
        
        let backgroundConstraints = [
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
        ]
        
        NSLayoutConstraint.activate(backgroundConstraints)
        /*
        attachedConstraints = [
            child
                .leadingAnchor
                .constraint(
                    equalTo: leadingAnchor,
                    constant: 0
                ),
            child
                .trailingAnchor
                .constraint(
                    equalTo: trailingAnchor,
                    constant: 0
                ),
            child
                .topAnchor
                .constraint(
                    equalTo: topAnchor,
                    constant: 0
                ),
            child
                .bottomAnchor
                .constraint(
                    equalTo: bottomAnchor,
                    constant: 0
                ),
        ]
        
        NSLayoutConstraint.activate(attachedConstraints)*/
        attachedConstraints = [
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor),
        ]
        NSLayoutConstraint.activate(attachedConstraints)
    }
}

extension ButtonStyle {
    fileprivate func updateBackground(_ button: UICustomButton) {
        button.button.isHidden = [.plain, .borderless].contains(self)
    }
    
    fileprivate func setConstraints(_ button: UICustomButton) {
        /*guard
            ![.plain, .borderless].contains(self),
            button.attachedConstraints.count == 4
        else {
            for constraint in button.attachedConstraints {
                constraint.constant = 0
            }
            return
        }
        
        button.attachedConstraints[0].constant = UICustomButton.horizontalPadding
        button.attachedConstraints[1].constant = -UICustomButton.horizontalPadding
        button.attachedConstraints[2].constant = UICustomButton.verticalPadding
        button.attachedConstraints[3].constant = -UICustomButton.verticalPadding*/
    }
}
