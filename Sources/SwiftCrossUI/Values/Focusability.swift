/// Enables finer-grained control of ``View/focusable``
///
/// ``Focusability/unmodified`` maintains the existing focus
/// of the view graph without adding or removing tab stops.

// Used as an alternative to Bool in View/focusable
//
// @State var canBecomeKeyView: Bool ...
// TextField(...).focusable(canBecomeKeyView)
//
// would create a second tab stop around TextField when enabled
//
// This can be prevented by doing
//
// TextField(...)
//      .if(!canBecomeKeyView) { view in
//          view.focusable(false)
//      }
//
// Using the enum has two benefits:
// - no nesting in Views required
// - it can update the focus control widget instead
//   of altering the backend's graph with every change
@frozen
public enum Focusability: String, CaseIterable, Sendable, Codable {
    // Inserts a new tab stop into the focus chain
    // disabled until backends properly support it, can currently be buggy in reverse
    // case enabled
    /// Does not alter focus chain; view graph behaves as it would without the modifier
    case unmodified
    /// Prevents the view and its subtree from receiving focus by keyboard.
    case disabled
}
