import Gtk3
import CGtk3
import SwiftCrossUI

extension Gtk3Backend {
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
        let button = button as! Gtk3.Button
        button.sensitive = environment.isEnabled
        button.label = label
        button.clicked = { _ in action() }
        button.css.clear()
        button.css.set(
            properties: Self.cssProperties(for: environment, isControl: true)
        )
    }
    
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = GtkCustomButton()
        gtk_container_add(button.widgetPointer.cast(), widget.widgetPointer)
        
        gtk_widget_set_halign(widget.widgetPointer, GTK_ALIGN_CENTER)
        gtk_widget_set_valign(widget.widgetPointer, GTK_ALIGN_CENTER)
        
        return button
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! GtkCustomButton
        button.clicked = { _ in action() }
        button.buttonStyle = environment.buttonStyle ?? defaultButtonStyle()
        button.sensitive = environment.isEnabled
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? defaultButtonStyle() {
            case .bordered: SIMD2<Int>(
                Int(GtkCustomButton.horizontalPadding * 2),
                Int(GtkCustomButton.verticalPadding * 2)
            )
            case .plain, .borderless: SIMD2<Int>(0, 0)
        }
    }
    
    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}

fileprivate final class GtkCustomButton: Gtk3.Button {
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
    
    init() {
        super.init(gtk_button_new())
        
        let context = gtk_widget_get_style_context(widgetPointer)
        gtk_style_context_add_class(context, "customButton")
        
        loadCSS()
    }
    
    private func loadCSS() {
        cssProvider.loadCss(from: """
        button.customButton {
            min-width: 0px;
            min-height: 0px;
            padding: 0px;
        }

        button.customButton.flat:active {
            opacity: 0.65;
        }

        button.customButton.flat {
            background-image: none;
            background-color: transparent;
            border-color: transparent;
            box-shadow: none;
        }

        button.customButton.flat:focus {
            -gtk-outline-radius: 0px;
            outline-offset: 0px;
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
            let context = gtk_widget_get_style_context(button.widgetPointer)
            gtk_style_context_add_class(context, cssClass)
        }
    }
    
    fileprivate func removeClass(_ button: GtkCustomButton) {
        if let cssClass {
            let context = gtk_widget_get_style_context(button.widgetPointer)
            gtk_style_context_remove_class(context, cssClass)
        }
    }
    
    var cssClass: String? {
        switch self {
            case .bordered: nil
            case .plain, .borderless: "flat"
        }
    }
}
