import Foundation

/// A geometric angle whose value you access in either radians or degrees.
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

    /// Creates an angle based on the direction between two unit points.
    /// - Parameters:
    ///   - origin: The starting point of the vector.
    ///   - destination: The end point used to calculate the angle from the origin.
    public init(origin: UnitPoint, destination: UnitPoint) {
        let deltaX = destination.x - origin.x
        let deltaY = destination.y - origin.y

        self.init(radians: atan2(deltaY, deltaX))
    }

    public static let conversionFactor = Double.pi / 180

    public static func + (lhs: Self, rhs: Self) -> Self {
        Angle(degrees: lhs.degrees + rhs.degrees)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        Angle(degrees: lhs.degrees - rhs.degrees)
    }
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
