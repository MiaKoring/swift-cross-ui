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
            buttonStyle: Int32(
                (environment.buttonStyle ?? defaultButtonStyle()).rawValue
            ),
            isEnabled: environment.isEnabled
        )
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        switch environment.buttonStyle ?? defaultButtonStyle() {
            case .bordered: SIMD2(
                    CustomButton.horizontalPadding * 2,
                    CustomButton.verticalPadding * 2
                )
            case .plain, .borderless: SIMD2(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}
