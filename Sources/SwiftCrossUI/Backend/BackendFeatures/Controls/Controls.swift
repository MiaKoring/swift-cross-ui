extension BackendFeatures {
    /// Backend methods for built-in controls.
    ///
    /// ## Topics
    ///
    /// ### Constituent Protocols
    /// - ``Buttons``
    /// - ``Toggles``
    /// - ``Switches``
    /// - ``Checkboxes``
    /// - ``Sliders``
    /// - ``TextFields``
    /// - ``SecureFields``
    /// - ``TextEditors``
    /// - ``Pickers``
    /// - ``ProgressSpinners``
    /// - ``ProgressBars``
    public typealias Controls =
        Buttons & SimpleButtons & ToggleButtons & Switches & Checkboxes & Sliders
            & TextFields & SecureFields & TextEditors & Pickers & ProgressSpinners
            & ProgressBars
}
