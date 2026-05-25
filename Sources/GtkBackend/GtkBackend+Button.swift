import Gtk
import CGtk
import GtkCHelpers
import SwiftCrossUI

extension GtkBackend {
    public func createSimpleButton() -> Widget {
        return Button()
    }
    
    public func updateSimpleButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        // TODO: Update button label color using environment
        let button = button as! Gtk.Button
        button.sensitive = environment.isEnabled
        button.label = label
        button.clicked = { _ in action() }
        button.css.clear()
        button.css.set(properties: Self.cssProperties(for: environment, isControl: true))
    }
    
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = GtkCustomButton()
        button.put(widget, index: 0, x: 0, y: 0)
        return button
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! GtkCustomButton
        button.action = action
        button.buttonStyle = environment.buttonStyle ?? .plain
        button.isEnabled = environment.isEnabled
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? .bordered {
            case .bordered: SIMD2<Int>(
                GtkCustomButton.horizontalPadding * 2,
                GtkCustomButton.verticalPadding * 2
            )
            case .plain: SIMD2<Int>(0, 0)
        }
    }
}

public final class GtkCustomButton: Gtk.Fixed {
    #if os(macOS)
    static let horizontalPadding: Int = 11
    static let verticalPadding: Int = 4
    #else
    static let horizontalPadding: Int = 11
    static let verticalPadding: Int = 4
    #endif
    
    fileprivate var action: (() -> Void)?
    fileprivate var buttonStyle: ButtonStyle = .bordered {
        didSet { }
    }
    
    var isEnabled = true {
        didSet {
            sensitive = isEnabled
            buttonStyle.applyModifications(self)
        }
    }
    
    // Whether left mousebutton is pressed on this view.
    private var isPressed = false
    
    public var isHighlighted = false {
        didSet {
            buttonStyle.handleHighlight(self)
        }
    }
    
    var dragStart = SIMD2(0.0, 0.0)
    
    override init() {
        super.init()
        
        let clickGesture = GestureClick()
        clickGesture.pressed = { [weak self] _, _, _, _ in
            guard let self, isEnabled else { return }
            isPressed = true
            isHighlighted = true
        }
        
        clickGesture.released = { [weak self] _, _, x, y in
            guard let self, isEnabled else { return }
            
            let width = Int(gtk_widget_get_size(widgetPointer, GTK_ORIENTATION_HORIZONTAL))
            let height = Int(gtk_widget_get_size(widgetPointer, GTK_ORIENTATION_VERTICAL))
            
            if (0...width).contains(Int(x)) && (0...height).contains(Int(y)) {
                action?()
            }
            
            isPressed = false
            isHighlighted = false
        }
        
        let dragGesture = GestureDrag()
        
        dragGesture.dragBegin = { [weak self] _, startX, startY in
            guard let self, isEnabled else { return }
            
            dragStart = SIMD2(startX, startY)
        }
        
        dragGesture.dragUpdate = { [weak self] _, offsetX, offsetY  in
            guard let self, isEnabled else { return }
            
            let currentX = dragStart.x + offsetX
            let currentY = dragStart.y + offsetY
            
            let width = gtk_widget_get_size(widgetPointer, GTK_ORIENTATION_HORIZONTAL)
            let height = gtk_widget_get_size(widgetPointer, GTK_ORIENTATION_VERTICAL)
            
            if
                (0.0...Double(width)).contains(currentX)
                && (0.0...Double(height)).contains(currentY)
            {
                isHighlighted = true
            } else {
                isHighlighted = false
            }
        }
        
        addEventController(clickGesture)
        addEventController(dragGesture)
    }
}

extension ButtonStyle {
    func applyModifications(_ button: GtkCustomButton) {
        switch self {
            case .plain, .bordered:
                button.opacity = button.isEnabled ? 1.0: 0.5
        }
    }
    
    func handleHighlight(_ button: GtkCustomButton) {
        switch self {
            case .plain, .bordered:
                if button.isHighlighted {
                    button.opacity = 0.75
                } else {
                    button.opacity = 1.0
                }
        }
    }
}
