/// A color gradient represented as an array of color stops, each having a parametric location value.
public struct Gradient {
    /// The array of color stops.
    public var stops: [Gradient.Stop]

    /// Creates a gradient from an array of color stops.
    init(stops: [Gradient.Stop]) {
        self.stops = stops
    }

    /// Creates a gradient from an array of colors.
    ///
    /// The gradient synthesizes its location values to evenly space the colors along the gradient.
    init(colors: [Color]) {
        guard
            let first = colors.first
        else {
            let invisible = Color.black.opacity(0)
            self.stops = [
                Stop(color: invisible, location: 0),
                Stop(color: invisible, location: 1),
            ]
            return
        }

        if colors.count == 1 {
            self.stops = [
                Stop(color: first, location: 0),
                Stop(color: first, location: 1),
            ]
            return
        }

        let locationDifference = 1.0 / Double(colors.count - 1)

        var stops = [Stop(color: first, location: 0)]
        var currentLocation = 0.0

        for color in colors[1...] {
            currentLocation += locationDifference
            stops.append(
                Stop(color: color, location: currentLocation)
            )
        }

        self.stops = stops
    }

    /// One color stop in the gradient.
    public struct Stop {
        /// Creates a color stop with a color and location.
        public init(color: Color, location: Double) {
            self.color = color
            self.location = location
        }

        /// The color for the stop.
        public var color: Color
        /// The parametric location of the stop.
        public var location: Double
    }
}
