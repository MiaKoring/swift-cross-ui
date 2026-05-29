/// A control that initiates an action.
public struct Button<Content: View>: Sendable {
    @Environment(\.foregroundColor) var color
    @Environment(\.isEnabled) var isEnabled
    /// The label to show on the button.
    public var body: Content
    /// The action to be performed when the button is clicked.
    package var action: @MainActor @Sendable () -> Void

    public let label: String?

    /// Creates a button that displays a text label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    public init(
        _ label: String,
        action: @escaping @MainActor @Sendable () -> Void = {}
    ) where Content == Text {
        self.body = Text(label)
        self.action = action
        self.label = label
    }

    /// Creates a button that displays a custom view as label.
    ///
    /// - Parameters:
    ///   - label: The label to show on the button.
    ///   - action: The action to be performed when the button is clicked.
    @MainActor
    public init (
        action: @escaping @MainActor @Sendable () -> Void = {},
        @ViewBuilder label: @escaping @MainActor @Sendable () -> Content
    ) {
        self.body = label()
        self.action = action
        self.label = nil
    }
}

@MainActor
extension Button: TypeSafeView {
    typealias Children = ButtonLabelChild<Content>

    func children<Backend: BaseAppBackend>(
        backend: Backend,
        snapshots: [ViewGraphSnapshotter.NodeSnapshot]?,
        environment: EnvironmentValues
    ) -> Children {
        let children = Children()
        children.child = AnyViewGraphNode(for: body, backend: backend, environment: environment)
        return children
    }

    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {
        backend.createButton(wrapping: children.widgets.first!.into())
    }

    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: Children,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult {
        var childEnvironment = environment

        let defaultButtonStyle = backend.defaultButtonStyle()

        if
            !environment.isEnabled,
            environment.buttonStyle ?? defaultButtonStyle != .plain
        {
            childEnvironment = childEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .gray.opacity(0.5)
            )
        }

        // Set the default foregroundColor for the label unless overridden.
        // Uses the same colors as SwiftUI.
        if
            environment.buttonStyle ?? defaultButtonStyle == .borderless,
            backend.deviceClass == .desktop
        {
            childEnvironment = childEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .gray
            )
        } else if environment.buttonStyle ?? defaultButtonStyle == .borderless {
            childEnvironment = childEnvironment.with(
                \.foregroundColor,
                environment.foregroundColor ?? .blue // TODO: Replace with .accent
            )
        }

        let childrenResult = children.child!.computeLayout(
            with: body,
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
        backend.setSize(of: widget, to: layout.size.vector)
        _ = children.child?.commit()
    }
}

class ButtonLabelChild<Child: View>: ViewGraphNodeChildren {
    var child: AnyViewGraphNode<Child>?

    var widgets: [AnyWidget] {
        if let child { return [child.widget] }
        return []
    }

    var erasedNodes: [ErasedViewGraphNode] {
        if let child { return [ErasedViewGraphNode(wrapping: child)] }
        return []
    }
}
