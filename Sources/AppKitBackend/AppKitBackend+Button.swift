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
        
        print(child)
        
        button.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: NSCustomButton.horizontalPadding),
            child.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -NSCustomButton.horizontalPadding),
            child.topAnchor.constraint(equalTo: button.topAnchor, constant: NSCustomButton.verticalPadding),
            child.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -NSCustomButton.verticalPadding),
            child.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            child.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
        
        child.wantsLayer = true
        button.wantsLayer = true
        
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
    }
}

public final class NSCustomButton: NSView {
    static let horizontalPadding: CGFloat = 8.0
    static let verticalPadding: CGFloat = 4.0
    
    fileprivate var action: (() -> Void)?
    
    fileprivate let cell = NSButtonCell()
    
    // Whether left mousebutton is pressed on this view.
    private var isPressed = false {
        didSet {
            if !isPressed && !isKeyboardDown, !suppressMouseAction {
                action?()
            }
            suppressMouseAction = false
        }
    }
    
    // Whether the spacebar (button activation) is pressed on this view.
    private var isKeyboardDown = false {
        didSet {
            if !isKeyboardDown && !isPressed {
                action?()
            }
        }
    }
    
    private var suppressMouseAction = false
    
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
    
    override public func draw(_ dirtyRect: NSRect) {
        cell.drawBezel(withFrame: self.bounds, in: self)
        
        super.draw(dirtyRect)
    }
    
    override public var acceptsFirstResponder: Bool {
        // Even though its called FullKeyboardAccess, it actuall corresponds to
        // the Keyboard navigation setting.
        NSApplication.shared.isFullKeyboardAccessEnabled
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
        cell.drawFocusRingMask(withFrame: bounds, in: self)
    }
    
    override public func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers ?? ""
        
        if characters == " " {
            isKeyboardDown = true
        } else {
            super.keyDown(with: event)
        }
    }
    
    override public func keyUp(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers ?? ""
        
        if characters == " " {
            isKeyboardDown = false
        } else {
            super.keyUp(with: event)
        }
    }
    
    override public func mouseDown(with _: NSEvent) {
        isPressed = true
    }
    
    override public func mouseUp(with event: NSEvent) {
        let pointInView = self.convert(event.locationInWindow, from: nil)
        
        if !bounds.contains(pointInView) {
            suppressMouseAction = true
        }
        
        isPressed = false
    }
}
