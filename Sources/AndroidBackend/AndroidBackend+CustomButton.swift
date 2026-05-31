import AndroidKit
import SwiftCrossUI

extension AndroidBackend {
    public func createButton(wrapping widget: Widget) -> Widget {
        let button = CustomButton(Self.activity, environment: Self.env)
        button.addView(widget.as(AndroidKit.View.self)!, 0)
        // When I tried setting it in the initializer somehow click stopped working?
        button.setPadding(
            horizontal: Int32(CustomButton.horizontalPadding),
            vertical: Int32(CustomButton.verticalPadding)
        )
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
        return switch environment.resolvedButtonStyle.kind {
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
