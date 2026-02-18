/// A radial gradient.
public struct RadialGradient: ElementaryView {
    /// The gradient represented as an array of color stops, each having a parametric location value.
    public let gradient: Gradient
    /// The radius the gradient starts laying out colors.
    /// The circle smaller than this radius gets filled with the first color.
    public let startRadius: Double
    /// The radius the gradient stops laying out colors.
    /// The circle bigger than this radius gets filled with the last color.
    public let endRadius: Double
    /// The normalized center point of the gradient in its coordinate space.
    public let center: UnitPoint
    
    private static let idealSize = ViewSize(10, 10)
    
    /// Creates a radial gradient from a base gradient.
    public init(
        gradient: Gradient,
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.gradient = gradient
        self.startRadius = startRadius
        self.center = center
        self.endRadius = endRadius
    }
    
    func asWidget<Backend>(
        backend: Backend
    ) -> Backend.Widget where Backend: AppBackend {
        backend.createRadialGradient()
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
        backend.updateRadialGradient(
            widget,
            gradient: self,
            withSize: layout.size.vector,
            in: environment
        )
    }
}

extension RadialGradient {
    /// Creates a radial gradient from a collection of colors.
    public init(
        stops: [Gradient.Stop],
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.init(
            gradient: Gradient(stops: stops),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
    
    /// Creates a radial gradient from a collection of color stops.
    public init(
        colors: [Color],
        center: UnitPoint,
        startRadius: Double,
        endRadius: Double
    ) {
        self.init(
            gradient: Gradient(colors: colors),
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }
    
    /// Stops adjusted to accomodate startRadius on backends without native support.
    public var adjustedStops: [Gradient.Stop] {
        let range = endRadius - startRadius
        
#if DEBUG
        if range < 0 {
            logger.warning(
                """
                The difference between endRadius and startRadius \
                must be >= 0 on 'RadialGradient'.
                """
            )
            return gradient.stops
        }
#endif
        
        let dividableRange = range / endRadius
        let innerCircle = (endRadius - range) / endRadius
        
        return gradient.stops.map {
            Gradient.Stop(
                color: $0.color,
                location: innerCircle + $0.location * dividableRange
            )
        }
    }
}
