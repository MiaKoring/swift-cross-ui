import SwiftCrossUI
import WinUI

extension WinUIBackend {
    public func createButton(
        wrapping widget: Widget
    ) -> Widget {
        let button = CustomButton()
        button.content = widget
        return button
    }
    
    public func updateButton(
        _ button: Widget,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let button = button as! CustomButton
        internalState.buttonClickActions[ObjectIdentifier(button)] = action
    }

    public func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int> {
        SIMD2(12, 6)
    }
    
    public func defaultButtonStyle() -> ButtonStyle { .bordered }
}

final class CustomButton: WinUI.Button {
    
}
