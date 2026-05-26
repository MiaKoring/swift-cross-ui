import AppKit
import SwiftCrossUI

extension AppKitBackend {
    public func createSimpleButton() -> Widget {
        NSButton()
    }
    
    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        
        let button = button as! NSButton
        button.attributedTitle = Self.attributedString(
            for: label,
            in: environment.with(\.multilineTextAlignment, .center)
        )
        button.bezelStyle = .regularSquare
        button.appearance = environment.colorScheme.nsAppearance
        button.isEnabled = environment.isEnabled
        button.onAction = { _ in
            action()
        }
    }
    
    public func createButton(
        wrapping child: Widget
    ) -> NSView {
        let button = NSCustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    public func updateButton(
        _ button: NSView,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! NSCustomButton
        button.cell.bezelStyle = .flexiblePush
        button.cell.isEnabled = environment.isEnabled
        
        button.action = action
        
        button.isEnabled = environment.isEnabled
        
        button.buttonStyle = environment.buttonStyle ?? .bordered
        
        button.buttonStyle.setConstraints(button)
        
        setSize(of: button.subviews.first!, to: .init(50, 50))
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? .bordered {
            case .bordered: SIMD2<Int>(
                Int(NSCustomButton.horizontalPadding * 2),
                Int(NSCustomButton.verticalPadding * 2)
            )
            case .plain: SIMD2<Int>(0, 0)
        }
    }
}

public final class NSCustomButton: NSView {
    static let horizontalPadding: CGFloat = 11.0
    static let verticalPadding: CGFloat = 4.0
    
    fileprivate var action: (() -> Void)?
    fileprivate let cell = NSButtonCell()
    fileprivate var buttonStyle: ButtonStyle = .bordered {
        didSet { updateButtonAppearance() }
    }
    
    var isEnabled = true {
        didSet { updateButtonAppearance() }
    }
    
    // Whether left mousebutton is pressed on this view.
    private var isPressed = false
    
    public var isHighlighted = false {
        didSet {
            buttonStyle.handleHighlight(self)
            self.needsDisplay = true
        }
    }
    
    init() {
        cell.title = ""
        cell.isBordered = true
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        cell.title = ""
        cell.isBordered = true
        super.init(coder: coder)
    }
    
    public override init(frame frameRect: NSRect) {
        cell.title = ""
        cell.isBordered = true
        super.init(frame: frameRect)
    }
    
    public override func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        if buttonStyle.shouldRenderNativeBackground {
            cell.drawBezel(withFrame: self.bounds, in: self)
        }
        
        super.draw(dirtyRect)
    }
    
    override public var acceptsFirstResponder: Bool {
        // Even though its called FullKeyboardAccess, it actuall corresponds to
        // the Keyboard navigation setting.
        isEnabled && NSApplication.shared.isFullKeyboardAccessEnabled
    }
    
    override public var focusRingMaskBounds: NSRect { bounds }
    
    override public func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok { noteFocusRingMaskChanged() }
        return ok
    }
    
    override public func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if ok { noteFocusRingMaskChanged() }
        return ok
    }
    
    override public func drawFocusRingMask() {
        guard isEnabled else { return }
        buttonStyle.drawFocusRingMask(on: self)
    }
    
    override public func keyDown(with event: NSEvent) {
        guard isEnabled else { return }
        
        let characters = event.charactersIgnoringModifiers ?? ""
        
        if characters == " " {
            isHighlighted = true
            action?()
            
            // Task with Task.sleep could be used in the future,
            // it has a min version requirement of macOS 13.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isHighlighted = false
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
    override public func mouseDown(with _: NSEvent) {
        guard isEnabled else { return }
        
        isPressed = true
        isHighlighted = true
    }
    
    override public func mouseDragged(with event: NSEvent) {
        guard isEnabled else { return }
        
        let pointInView = convert(event.locationInWindow, from: nil)
        
        if isPressed && bounds.contains(pointInView) {
            isHighlighted = true
        } else {
            isHighlighted = false
        }
    }
    
    override public func mouseUp(with event: NSEvent) {
        guard isEnabled else { return }
        
        let pointInView = self.convert(event.locationInWindow, from: nil)
        
        if bounds.contains(pointInView) {
            action?()
        }
        
        isPressed = false
        isHighlighted = false
    }
    
    private func updateButtonAppearance() {
        buttonStyle.applyModifications(self)
        noteFocusRingMaskChanged()
        self.needsDisplay = true
    }
}

extension ButtonStyle {
    func applyModifications(_ button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.isEnabled = button.isEnabled
            case .plain:
                button.alphaValue = button.isEnabled ? 1.0: 0.5
        }
    }
    
    var shouldRenderNativeBackground: Bool {
        switch self {
            case .bordered:
                true
            case .plain:
                false
        }
    }
    
    func drawFocusRingMask(on button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.drawFocusRingMask(withFrame: button.bounds, in: button)
            case .plain:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
    
    func setConstraints(_ button: NSCustomButton) {
        let child = button.subviews.first!
        var constraints = [
            child.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: NSCustomButton.horizontalPadding),
            child.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -NSCustomButton.horizontalPadding),
            child.topAnchor.constraint(equalTo: button.topAnchor, constant: NSCustomButton.verticalPadding),
            child.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -NSCustomButton.verticalPadding)
        ]
        
        guard self != .plain else {
            child.removeConstraints(constraints)
            return
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func handleHighlight(_ button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.isHighlighted = button.isHighlighted
            case .plain:
                if button.isHighlighted {
                    button.alphaValue = 0.75
                } else {
                    button.alphaValue = 1.0
                }
        }
    }
}
