extension View {
    /// Controls the focusability of a view.
    /// Only affects out of the box interactable Views.
    ///
    /// Doesn't have an effect on UIKitBackend and WinUIBackend.
    public func focusable(_ focusability: Focusability = .unmodified) -> some View {
        FocusModifier(body: TupleView1(self), focusability: focusability)
    }
}
