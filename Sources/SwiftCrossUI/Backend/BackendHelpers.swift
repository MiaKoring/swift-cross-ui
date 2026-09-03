enum BackendHelpers {
    /// Sets the ``WidgetFocusObserver``s from the environment on a widget.
    static func setWidgetFocusObservers<Backend2: BackendFeatures.Focus>(
        of widget: AnyWidget,
        with backend: Backend2,
        environment: EnvironmentValues
    ) {
        backend.registerFocusObservers(
            environment.focusObservers,
            on: widget.widget as! Backend2.Widget
        )
        
        backend.setFocusEffectDisabled(
            on: widget.widget as! Backend2.Widget,
            disabled: environment.focusEffectDisabled
        )
    }
}
