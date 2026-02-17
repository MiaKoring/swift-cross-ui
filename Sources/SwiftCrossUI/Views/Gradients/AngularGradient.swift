/// An angular gradient.
public struct AngularGradient: ElementaryView {
    /// The gradient represented as an array of color stops, each having a parametric location value.
    public let gradient: Gradient
    /// The normalized center point of the gradient in its coordinate space.
    public let center: UnitPoint

    private static let idealSize = ViewSize(10, 10)

    /// Creates a conic gradient that completes a full turn.
    public init(
        gradient: Gradient,
        center: UnitPoint
    ) {
        self.gradient = gradient
        self.center = center
    }

    func asWidget<Backend>(
        backend: Backend
    ) -> Backend.Widget where Backend: AppBackend {
        backend.createAngularGradient()
    }

    func computeLayout<Backend>(
        _ widget: Backend.Widget,
        proposedSize: ProposedViewSize,
        environment: EnvironmentValues,
        backend: Backend
    ) -> ViewLayoutResult where Backend: AppBackend {
        ViewLayoutResult.leafView(
            size: proposedSize.replacingUnspecifiedDimensions(by: Self.idealSize)
        )
    }

    func commit<Backend>(
        _ widget: Backend.Widget,
        layout: ViewLayoutResult,
        environment: EnvironmentValues,
        backend: Backend
    ) where Backend: AppBackend {
        backend.setSize(of: widget, to: layout.size.vector)
        backend.updateAngularGradient(
            widget,
            gradient: self,
            withSize: layout.size.vector,
            in: environment
        )
    }
}

extension AngularGradient {
    /// Creates a conic gradient from a collection of colors that completes a full turn.
    public init(
        colors: [Color],
        center: UnitPoint
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center
        )
    }

    /// Creates a conic gradient from a collection of color stops that completes a full turn.
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center
        )
    }
}
