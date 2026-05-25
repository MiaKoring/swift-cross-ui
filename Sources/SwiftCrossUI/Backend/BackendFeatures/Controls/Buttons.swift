extension BackendFeatures {
    /// Backend methods for buttons.
    ///
    /// These are used by ``Button`` and ``Menu``.
    @MainActor
    public protocol Buttons: Core {
        func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int>
        /// Creates a labelled button with an action triggered on click/tap.
        ///
        /// Predominantly used by ``SimpleButton``.
        ///
        /// - Returns: A button.
        func createSimpleButton() -> Widget

        /// Sets a button's label and action.
        ///
        /// - Parameters:
        ///   - button: The button to update.
        ///   - label: The button's label.
        ///   - environment: The current environment.
        ///   - action: The action to perform when the button is clicked/tapped.
        ///     This replaces any existing actions.
        func updateSimpleButton(
            _ button: Widget,
            label: String,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )
        
        func createButton(wrapping: Widget) -> Widget
        
        func updateButton(
            _ button: Widget,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )
    }
}
