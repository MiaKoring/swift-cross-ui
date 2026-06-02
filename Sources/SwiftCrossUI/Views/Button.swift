/// A control that initiates an action.
public struct Button<Label: View> {
    public typealias Content = TupleView1<Label>
    /// The label to show on the button.
    public var label: () -> Label
    /// The action to be performed when the button is clicked.
    package var action: @MainActor @Sendable () -> Void
    
    public var stringLabel: String?

    /// Creates a button that displays a text label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    public init(
        _ label: String,
        action: @escaping @MainActor @Sendable () -> Void = {}
    ) where Label == TupleView1<Text> {
        self.label = { TupleView1(Text(label)) }
        self.action = action
        self.stringLabel = label
    }

    /// Creates a button that displays a custom view as label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    @MainActor
    public init (
        action: @escaping @MainActor @Sendable () -> Void = {},
        @ViewBuilder label: @escaping @MainActor @Sendable () -> Label
    ) {
        self.label = label
        self.action = action
    }
}

@MainActor
extension Button: TypeSafeView {
    public var body: TupleView1<Label> {
        label()
    }
    
    typealias Children = TupleViewChildren1<Label>

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        Children(label(), backend: backend, snapshots: snapshots, environment: environment)
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        backend.createButton(wrapping: children.child0.widget.into())
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var childEnvironment = environment

        let buttonStyle = environment.resolvedButtonStyle.kind

        if !environment.isEnabled, buttonStyle == .bordered {
            if backend.deviceClass == .desktop || backend.deviceClass == .tv {
                childEnvironment = childEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor ?? .gray
                        .opacity(0.5) // SwiftUI is closer to secondary.
                )
            } else if backend.deviceClass == .phone || backend.deviceClass == .tablet {
                childEnvironment = childEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor?.opacity(0.8) ?? .blue.opacity(0.8)
                )
            } else if backend.deviceClass == .tv {
                childEnvironment = childEnvironment.with(
                    \.foregroundColor,
                    environment.foregroundColor ?? .white.opacity(0.5)
                )
            }
        }
        // The disabled opacities and defaults are based on discoveries in SwiftUI.
        // iOS appears to dimm even foregroundColors in the environment.

        // Set the default foregroundColor for the label unless overridden.
        // Uses the same colors as SwiftUI.
        if
            buttonStyle == .borderless,
            backend.deviceClass == .desktop
        {
            childEnvironment = childEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .gray
            )
        } else if
            backend.deviceClass == .phone || backend.deviceClass == .tablet,
            buttonStyle == .borderless || buttonStyle == .bordered
        {
            childEnvironment = childEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .blue // TODO: Replace with .accent
            )
        }

        let childrenResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: childEnvironment
        )

        backend.updateButton(
            widget,
            environment: environment,
            action: action
        )

        let buttonPadding = backend.buttonPadding(in: environment)

        // Buttons should always be set to label size + padding.
        // The backend representation of a button is expected not to have a minSize.
        let size = SIMD2(
            Int(childrenResult.size.width) + buttonPadding.x,
            Int(childrenResult.size.height) + buttonPadding.y
        )

        return ViewLayoutResult.leafView(size: ViewSize(size))
    }

    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        if Label.self != Text.self {
            children.child0.commit()
        }
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
