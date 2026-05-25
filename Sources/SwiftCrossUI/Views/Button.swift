/// A control that initiates an action.
public struct Button<Content: View>: Sendable {
    /// The label to show on the button.
    public var body: TupleView1<Content>
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
        self.body = TupleView1(Text(label))
        self.action = action
    }
    
    @MainActor
    public init (
        action: @escaping @MainActor @Sendable () -> Void = {},
        @ViewBuilder label: @escaping @MainActor @Sendable () -> Content
    ) {
        self.body = TupleView1(label())
        self.action = action
    }
}

@MainActor
extension Button: TypeSafeView {
    typealias Children = TupleView1<Content>.Children
    
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
    
    func asWidget<Backend: BaseAppBackend>(
        _ children: Children,
        backend: Backend
    ) -> Backend.Widget {        
        backend.createButton(wrapping: children.child0.widget.into())
    }
    
    func computeLayout<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleView1<Content>.Children,
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
        
        let childrenResult = children.child0.computeLayout(
            with: body.view0,
            proposedSize: proposedSize,
            environment: environment
        )
        
        backend.updateButton(
            widget,
            environment: environment,
            action: action
        )
        
        let size = SIMD2(
            Int(childrenResult.size.width) + 16,
            Int(childrenResult.size.height) + 8
        )
        
        print("size: \(size)")
        
        return ViewLayoutResult.leafView(size: ViewSize(size))
    }
    
    func commit<Backend: BaseAppBackend>(
        _ widget: Backend.Widget,
        children: TupleView1<Content>.Children,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) {
        backend.setSize(of: widget, to: layout.size.vector)
    }
}
