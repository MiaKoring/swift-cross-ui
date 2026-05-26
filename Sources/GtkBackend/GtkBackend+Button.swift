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
        button.buttonStyle = environment.buttonStyle ?? .bordered
        button.isEnabled = environment.isEnabled
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? .bordered {
            case .bordered: SIMD2<Int>(
                Int(GtkCustomButton.horizontalPadding * 2),
                Int(GtkCustomButton.verticalPadding * 2)
            )
            case .plain: SIMD2<Int>(0, 0)
        }
    }
}

fileprivate final class GtkCustomButton: CustomButton {
    static let horizontalPadding: Double = 9
    static let verticalPadding: Double = 4
    
    fileprivate var action: (() -> Void)?
    fileprivate var buttonStyle: ButtonStyle = .bordered {
        didSet {
            buttonStyle.setStyle(self)
        }
    }
    
    fileprivate var isEnabled = true {
        didSet {
            sensitive = isEnabled
            buttonStyle.applyModifications(self)
        }
    }
    
    fileprivate var isHovered = false {
        didSet {
            buttonStyle.setHoverStyle(self)
        }
    }
    
    fileprivate var isFocused = false {
        didSet {
            buttonStyle.setFocusRing(self)
        }
    }
    
    // Whether left mousebutton is pressed on this view.
    private var isPressed = false
    
    fileprivate var isHighlighted = false {
        didSet {
            buttonStyle.handleHighlight(self)
        }
    }
    
    private var dragStart = SIMD2(0.0, 0.0)
    
    init() {
        super.init(gtk_custom_button_new())
        
        addClickGesture()
        addDragGesture()
        addHoverGesture()
        addFocusController()
        addKeyController()
        
        focusable = true
    }
    
    private func addClickGesture() {
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
        
        addEventController(clickGesture)
    }
    
    private func addDragGesture() {
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
        
        addEventController(dragGesture)
    }
    
    private func addHoverGesture() {
        let hoverGesture = EventControllerMotion()
        
        hoverGesture.enter = { [weak self] _, _, _ in
            guard let self else { return }
            isHovered = true
        }
        
        hoverGesture.leave = { [weak self] _ in
            guard let self else { return }
            isHovered = false
        }
        
        addEventController(hoverGesture)
    }
    
    private func addFocusController() {
        let focusController = EventControllerFocus()
        
        focusController.enter = { [weak self] _ in
            guard let self else { return }
            isFocused = true
        }
        
        focusController.leave = { [weak self] _ in
            guard let self else { return }
            isFocused = false
        }
        
        addEventController(focusController)
    }
    
    private func addKeyController() {
        /*let keyController = EventControllerKey()
        keyController.keyPressed = { [weak self] controller, keyVal, _, modifers in
            guard
                let self,
                modifers == GDK_NO_MODIFIER_MASK
            else { return }
            
            if keyVal == GDK_KEY_space {
                action?()
                return true
            } else {
                return false
            }
        }
        
        addEventController(keyController)*/
    }
}

extension ButtonStyle {
    fileprivate func applyModifications(_ button: GtkCustomButton) {
        switch self {
            case .plain, .bordered:
                button.opacity = button.isEnabled ? 1.0: 0.5
        }
    }
    
    fileprivate func handleHighlight(_ button: GtkCustomButton) {
        switch self {
            case .plain, .bordered:
                if button.isHighlighted {
                    button.opacity = 0.75
                } else {
                    button.opacity = 1.0
                }
        }
    }
    
    // Styles are based on research made in:
    // https://github.com/GNOME/gtk/blob/main/gtk/theme/Default
    //
    // Where possible we use theme variables to avoid hardcoding.
    fileprivate func setStyle(_ button: GtkCustomButton) {
        button.css.clear()
        switch self {
            case .bordered:
                button.css.set(properties: [
                    CSSProperty(key: "background-color", value: "@theme_base_color"),
                    CSSProperty(key: "border", value: "1px solid @borders"),
                    CSSProperty(key: "border-radius", value: "5px"),
                    CSSProperty(
                        key: "padding",
                        value: """
                            \(GtkCustomButton.verticalPadding)px \
                            \(GtkCustomButton.horizontalPadding)px
                        """
                    )
                ])
            case .plain:
                break
        }
    }
    
    fileprivate func setHoverStyle(_ button: GtkCustomButton) {
        switch self {
            case .bordered:
                if button.isHovered {
                    button.css.set(properties: [
                        CSSProperty(key: "background-color", value: "shade(@theme_base_color, 0.86)")
                    ])
                } else {
                    button.css.set(properties: [
                        CSSProperty(key: "background-color", value: "@theme_base_color")
                    ])
                }
            case .plain:
                break
        }
    }
    
    fileprivate func setFocusRing(_ button: GtkCustomButton) {
        guard button.isFocused else {
            button.css.set(property: CSSProperty(key: "outline", value: "none"))
            return
        }
        
        switch self {
            case .bordered, .plain:
                button.css.set(properties: [
                    CSSProperty(
                        key: "outline",
                        value: "2px solid color-mix(in srgb, @theme_selected_bg_color 50%, transparent)"
                    ),
                    CSSProperty(key: "outline-offset", value: "-2px")
                ])
        }
    }
}
