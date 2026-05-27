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
        gtk_button_set_child(button.widgetPointer.cast(), widget.widgetPointer)
        
        gtk_widget_set_halign(widget.widgetPointer, GTK_ALIGN_CENTER);
        gtk_widget_set_valign(widget.widgetPointer, GTK_ALIGN_CENTER);
        
        return button
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! GtkCustomButton
        button.clicked = { _ in action() }
        button.buttonStyle = environment.buttonStyle ?? .bordered
        button.sensitive = environment.isEnabled
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
    
    public var shouldUseButtonContentForButtonSize: Bool { false }
}

fileprivate final class GtkCustomButton: Gtk.Button {
    static let horizontalPadding: Double = 12
    static let verticalPadding: Double = 6
    
    fileprivate var buttonStyle: ButtonStyle = .bordered {
        willSet {
            buttonStyle.removeClass(self)
        }
        didSet {
            buttonStyle.setClass(self)
        }
    }
    
    private var addedClasses = Set<String>()

    init() {
        super.init(gtk_button_new())
        
        gtk_widget_add_css_class(widgetPointer, "customButton")
        
        loadCSS()
    }
    
    private func loadCSS() {
        cssProvider.loadCss(from: """
        button.customButton {
            min-width: 0px;
            min-height: 0px;
            padding: 0px;
        }

        button.customButton.flat:active,
        button.customButton.flat.keyboard-activating {
            opacity: 0.65;
        }

        button.customButton.flat {
            background-color: transparent;
        }
        
        button.customButton.flat:focus {
            border-radius: 0px;
        }
        
        button.customButton.flat:disabled {
            opacity: 0.5;
        }
        """)
    }
}

extension ButtonStyle {
    fileprivate func setClass(_ button: GtkCustomButton) {
        if let cssClass {
            gtk_widget_add_css_class(button.widgetPointer, cssClass)
        }
    }
    
    fileprivate func removeClass(_ button: GtkCustomButton) {
        if let cssClass {
            gtk_widget_remove_css_class(button.widgetPointer, cssClass)
        }
    }
    
    var cssClass: String? {
        switch self {
            case .bordered: nil
            case .plain: "flat"
        }
    }
}
