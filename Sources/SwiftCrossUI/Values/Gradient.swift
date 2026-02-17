public struct Gradient {
    public var stops: [Gradient.Stop]

    init(stops: [Gradient.Stop]) {
        self.stops = stops
    }

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

    public struct Stop {
        public init(color: Color, location: Double) {
            self.color = color
            self.location = location
        }
        public var color: Color
        public var location: Double
    }
}
