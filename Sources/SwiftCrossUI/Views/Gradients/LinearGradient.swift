public struct LinearGradient: ElementaryView {
    public let gradient: Gradient
    public let startPoint: UnitPoint
    public let endPoint: UnitPoint

    private static let idealSize = ViewSize(10, 10)

    public init(
        gradient: Gradient,
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) {
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    func asWidget<Backend>(
        backend: Backend
    ) -> Backend.Widget where Backend: AppBackend {
        backend.createLinearGradient()
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
        backend.updateLinearGradient(
            widget,
            gradient: self,
            withSize: layout.size.vector,
            in: environment
        )
    }
}

extension LinearGradient {
    public init(
        stops: [Gradient.Stop],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    public init(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
