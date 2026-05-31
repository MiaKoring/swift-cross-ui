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
            action: SwiftAction(environment: Self.env, action: action),
            buttonStyle: environment.resolvedButtonStyle.kind.rawValue,
            isEnabled: environment.isEnabled,
            isDarkMode: environment.colorScheme == .dark
        )
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        let buttonClass = try! JavaClass<CustomButton>()
        return switch environment.resolvedButtonStyle.kind {
            case .bordered: SIMD2(
                    Int(buttonClass.horizontalPadding) * 2,
                    Int(buttonClass.verticalPadding) * 2
                )
            case .plain, .borderless: SIMD2(0, 0)
        }
    }

    public func defaultButtonStyle() -> ButtonStyle {
        .bordered
    }
}
