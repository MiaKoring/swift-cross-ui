public enum ButtonStyle: Sendable, Hashable {
    /// A button style that applies the standard border style based on the button’s context.
    case bordered
    /// A button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    case plain
}
