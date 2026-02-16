public struct Angle {
    public var degrees: Double
    public var radians: Double

    public init(degrees: Double) {
        self.degrees = degrees
        self.radians = degrees * Self.conversionFactor
    }

    public init(radians: Double) {
        self.degrees = radians / Self.conversionFactor
        self.radians = radians
    }

    public static let conversionFactor = Double.pi / 180
}

extension Angle {
    public static var zero: Self { Angle(degrees: 0) }

    public static func radians(_ radians: Double) -> Angle {
        Angle(radians: radians)
    }

    public static func degrees(_ degrees: Double) -> Angle {
        Angle(degrees: degrees)
    }
}
