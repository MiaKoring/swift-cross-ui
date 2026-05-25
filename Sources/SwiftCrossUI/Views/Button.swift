/// A control that initiates an action.
public struct Button<Content: View>: Sendable {
    /// The label to show on the button.
    public var body: Content
    /// The action to be performed when the button is clicked.
    package var action: @MainActor @Sendable () -> Void
    
    /// Creates a button that displays a custom label.
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
    }
    
    @MainActor
    public init (
        action: @escaping @MainActor @Sendable () -> Void = {},
        @ViewBuilder label: @escaping @MainActor @Sendable () -> Content
    ) {
        self.body = label()
        self.action = action
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
        // TODO: Implement button sizing within SwiftCrossUI so that we can move this to
        //   commit. Relying on the backend for button sizing also makes the Gtk 3 backend
        //   basically impossible to implement correctly, hence the
        //   `finalContentSize != contentSize` check in WindowGroupNode to catch any weird
        //   behaviour. Without that extra safety net logic, buttons all end up label-less
        //   whenever the window grows due to a view containing buttons appearing. Not sure
        //   why all buttons lose their labels (until you click off the window, forcing it to
        //   refresh), but the reason Gtk 3 doesn't like it is that the window gets set smaller
        //   than its content I think.
        //   See: https://github.com/moreSwift/swift-cross-ui/blob/27f50579c52e79323c3c368512d37e95af576c25/Sources/SwiftCrossUI/Scenes/WindowGroupNode.swift#L140
        
        let childrenResult = children.child!.computeLayout(
            with: body,
            proposedSize: proposedSize,
            environment: environment
        )
        
        backend.updateButton(
            widget,
            environment: environment,
            action: action
        )
        
        let size = SIMD2(
            Int(childrenResult.size.width) + backend.buttonPadding.x,
            Int(childrenResult.size.height) + backend.buttonPadding.y
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
        children.child?.commit()
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
