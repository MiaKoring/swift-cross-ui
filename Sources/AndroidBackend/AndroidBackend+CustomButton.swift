import AndroidKit
import SwiftCrossUI

extension AndroidBackend {
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = CustomButton(Self.activity, environment: Self.env)
        button.addView(widget.as(AndroidKit.View.self)!, 0)
        return button.as(AndroidKit.View.self)!
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button.as(CustomButton.self)!
        button.set(
            action: SwiftAction(action: action),
            buttonType: Int32((environment.buttonStyle ?? .bordered).rawValue),
            isEnabled: environment.isEnabled
        )
    }
    
    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        return SIMD2(
            CustomButton.horizontalPadding * 2,
            CustomButton.verticalPadding * 2
        )
    }
    
    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}
