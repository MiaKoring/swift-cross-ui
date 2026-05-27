public enum ButtonStyle: Sendable, Hashable {
    /// A button style that applies the standard border style based on the button’s context.
    case bordered
    /// A button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    case plain
    /// A button style that doesn’t apply a border.
    ///
    /// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
    /// due to the SwiftUI borderless behavior on mac being stupid.
    /// The only difference is a default foreground color of gray being applied.
    case borderless
}
