extension View {
    /// Set wether a View is focusable
    /// Only has effect on out of the box interactable Views
    /// doesn't work on Views using onTapGesture instead of Button
    public func focusable(_ isFocusable: Bool = true) -> some View {
        FocusModifier(body: TupleView1(self), focusability: isFocusable ? .enabled : .disabled)
    }

    public func focusable(_ focusability: Focusability = .unmodified) -> some View {
        FocusModifier(body: TupleView1(self), focusability: focusability)
    }

    public func focusEffectDisabled(_ disabled: Bool = true) -> some View {
        EnvironmentModifier(self) { environment in
            environment.with(\.focusEffectDisabled, disabled)
        }
    }

    public func focused<T, Value>(
        _ focusBinding: FocusState<Value>.Binding,
        equals match: T
    ) -> some View where Value == T?, T: Hashable {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    FocusData(
                        type: T.self,
                        match: match,
                        set: {
                            focusBinding.wrappedValue = match
                        },
                        reset: {
                            focusBinding.reset()
                        },
                        matches: focusBinding.wrappedValue == match
                    )
                ]
            )
        }
    }

    public func focused<T, Value>(
        _ focusBinding: FocusState<Value>.Binding
    ) -> some View where Value == T, T == Bool {
        EnvironmentModifier(self) { environment in
            environment.with(
                \.focusObservers,
                environment.focusObservers + [
                    FocusData(
                        type: T.self,
                        match: true,
                        set: {
                            focusBinding.wrappedValue = true
                        },
                        reset: {
                            focusBinding.reset()
                        },
                        matches: focusBinding.wrappedValue == true
                    )
                ]
            )
        }
    }
}

struct FocusModifier<Content: View>: TypeSafeView {
    typealias Children = TupleView1<Content>.Children

    var body: TupleView1<Content>
    var focusability: Focusability

    func children<Backend: AppBackend>(
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

    func asWidget<Backend: AppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        let container = backend.createFocusContainer()

        backend.insert(children.child0.widget.into(), into: container, at: 0)

        return container
    }

    func computeLayout<Backend>(
        _ widget: Backend.Widget, children: TupleView1<Content>.Children,
        proposedSize: ProposedViewSize, environment: EnvironmentValues, backend: Backend
    ) -> ViewLayoutResult where Backend: AppBackend {
        children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        .with(\.shouldSetFocusData, true)
    }

    func commit<Backend>(
        _ widget: Backend.Widget,
        children: TupleView1<Content>.Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) where Backend: AppBackend {
        let size = children.child0.commit().size.vector
        backend.setSize(of: widget, to: size)

        backend.updateFocusContainer(widget, focusability: focusability)
    }
}
