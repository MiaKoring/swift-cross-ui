extension View {
    /// Set wether a View is focusable
    /// Only has effect on out of the box interactable Views
    /// doesn't work on Views using onTapGesture instead of Button
    public func focusable(_ isFocusable: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.isFocusable, isFocusable)
        }
    }
}
