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
        button.setupContraints()
        
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
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? .bordered {
            case .bordered: SIMD2<Int>(
                Int(NSCustomButton.horizontalPadding * 2),
                Int(NSCustomButton.verticalPadding * 2)
            )
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }
    
    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
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
    
    private var highlightResetWorkItem: DispatchWorkItem?
    
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
    
    override public init(frame frameRect: NSRect) {
        cell.title = ""
        cell.isBordered = true
        super.init(frame: frameRect)
    }
    
    override public func accessibilityRole() -> NSAccessibility.Role? {
        .button
    }
    
    override public func accessibilityActionNames() -> [NSAccessibility.Action] {
        return [.press]
    }
    
    override public func accessibilityPerformPress() -> Bool {
        self.action?()
        return true
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        if buttonStyle.shouldRenderNativeBackground {
            cell.drawBezel(withFrame: self.bounds, in: self)
        }
        
        super.draw(dirtyRect)
    }
    
    override public var acceptsFirstResponder: Bool {
        // Even though its called FullKeyboardAccess, it actuall corresponds to
        // the "Keyboard navigation" setting.
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
        guard
            isEnabled,
            (event.charactersIgnoringModifiers ?? "") == " "
        else {
            super.keyDown(with: event)
            return
        }

        highlightResetWorkItem?.cancel()
        isHighlighted = true
        action?()
        
        // Task with Task.sleep could be used in the future,
        // it has a min version requirement of macOS 13.
        let workItem = DispatchWorkItem { [weak self] in
            self?.isHighlighted = false
        }
        highlightResetWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    override public func viewWillMove(toWindow newWindow: NSWindow?) {
        // Reset internal state when moved (or potentially re-used in the future).
        if newWindow == nil {
            highlightResetWorkItem?.cancel()
            isHighlighted = false
            isPressed = false
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
    
    fileprivate func setupContraints() {
        guard let child = subviews.first else { return }
        
        NSLayoutConstraint.activate([
            child.centerXAnchor.constraint(equalTo: centerXAnchor),
            child.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

extension ButtonStyle {
    fileprivate func applyModifications(_ button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.isEnabled = button.isEnabled
            case .plain, .borderless:
                button.alphaValue = button.isEnabled ? 1.0: 0.5
        }
    }
    
    fileprivate var shouldRenderNativeBackground: Bool {
        switch self {
            case .bordered:
                true
            case .plain, .borderless:
                false
        }
    }
    
    fileprivate func drawFocusRingMask(on button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.drawFocusRingMask(withFrame: button.bounds, in: button)
            case .plain, .borderless:
                let maskPath = NSBezierPath(rect: button.bounds)
                maskPath.fill()
        }
    }
    
    fileprivate func handleHighlight(_ button: NSCustomButton) {
        switch self {
            case .bordered:
                button.cell.isHighlighted = button.isHighlighted
            case .plain, .borderless:
                if button.isHighlighted {
                    button.alphaValue = 0.75
                } else {
                    button.alphaValue = 1.0
                }
        }
    }
}
