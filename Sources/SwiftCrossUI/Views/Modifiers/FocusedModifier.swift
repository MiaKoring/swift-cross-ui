extension View {
    /// Modifies this view by binding its focus state to the given state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `nil` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused<Value: Hashable>(
        _ focusBinding: FocusState<Value?>.Binding,
        equals match: Value
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    WidgetFocusObserver(
                        didGainFocus: {
                            focusBinding.wrappedValue = match
                        },
                        didLoseFocus: {
                            focusBinding.reset()
                        }
                    )
                ]
            )
            .with(
                \.focusOverride,
                 environment.focusOverride.modify(
                    with: focusBinding.wrappedValue,
                    match: match
                 )
            )
        }
    }

    /// Modifies this view by binding its focus state to the given Boolean state value.
    ///
    /// Supported by ``AppKitBackend``, ``GtkBackend`` and ``WinUIBackend``.
    ///
    /// Setting to `false` on ``WinUIBackend`` causes the first focusable widget to gain focus
    /// due to WinUI not supporting setting an "unfocused" state.
    public func focused(
        _ focusBinding: FocusState<Bool>.Binding
    ) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    WidgetFocusObserver(
                        didGainFocus: {
                            focusBinding.wrappedValue = true
                        },
                        didLoseFocus: {
                            focusBinding.reset()
                        }
                    )
                ]
            )
            .with(
                \.focusOverride,
                 environment.focusOverride != .focused
                 ? focusBinding.wrappedValue ? .focused : .unfocused
                 :.focused
            )
        }
    }
}

struct FocusModifier<Content: View>: TypeSafeView {
    typealias Children = TupleView1<Content>.Children

    var body: TupleView1<Content>
    var focusability: Focusability

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        body.children(
            backend: backend,
            snapshots: snapshots,
            environment: environment
        )
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createFocusContainer()

        backend.insert(children.child0.widget.into(), into: container, at: 0)

        return container as! Backend.Widget
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        .with(\.isNeverFocusable, false)
    }

    @CastBackend<BackendFeatures.FocusDisabling>(backendGenericName: "NewBackend")
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        let size = children.child0.commit().size.vector
        backend.setSize(of: widget, to: size)

        backend.updateFocusContainer(widget, focusability: focusability)
    }
}
