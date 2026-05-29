extension BackendFeatures {
    /// Backend methods for buttons.
    ///
    /// These are used by ``Button`` and ``Menu``.
    @MainActor
    public protocol Buttons: Core {
        /// Creates a labelled button with an action triggered on click/tap.
        ///
        /// Used by controls in button style like ``Menu`` or ``Toggle``.
        /// Will be removed in the future
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

        /// Creates a button supporting ``View`` as label with an action triggered on click/tap.
        ///
        /// Predominantly used by ``Button``.
        ///
        /// - Parameters:
        ///   - widget: The widget the button should use as label.
        ///
        /// - Returns: A button.
        func createButton(wrapping widget: Widget) -> Widget

        /// Sets a button's action and updates the rendered style based on the environment.
        ///
        /// - Parameters:
        ///   - button: The button to update.
        ///   - environment: The current environment.
        ///   - action: The action to perform when the button is clicked/tapped.
        ///     This replaces any existing actions.
        func updateButton(
            _ button: Widget,
            environment: EnvironmentValues,
            action: @escaping () -> Void
        )

        /// Buttons are set to label size + padding by SwiftCrossUI.
        /// Backends may choose different amounts of padding for different button styles.
        ///
        /// - Parameters:
        ///   - environment: The current environment.
        ///
        /// - Returns: A vector containing the **total** spacing horizontally and vertically.
        ///
        /// A padding of (0, 0) is recommended for all styles without a system defined background.
        func buttonPadding(in environment: EnvironmentValues) -> SIMD2<Int>

        /// The default style of a button the backend expects, that's used when no ``ButtonStyle`` is set.
        ///
        /// - Returns: The default ``ButtonStyle``.
        func defaultButtonStyle() -> ButtonStyle
    }
}
