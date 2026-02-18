import CGtk
import Gtk
import SwiftCrossUI

extension GtkBackend {
    public func createLinearGradient() -> Widget {
        Box()
    }

    public func updateLinearGradient(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! Box

        let startPoint = UnitPoint(
            x: Double(size.x) * gradient.startPoint.x,
            y: Double(size.y) * gradient.startPoint.y
        )

        let endPoint = UnitPoint(
            x: Double(size.x) * gradient.endPoint.x,
            y: Double(size.y) * gradient.endPoint.y
        )

        let angle = Angle(origin: startPoint, destination: endPoint)

        let stops = cssStops(gradient: gradient.gradient, environment: environment)

        widget.css.set(
            property: .init(
                key: "background",
                value: """
                    linear-gradient(\((angle + Angle(degrees: 90)).radians)rad, \(stops.joined(separator: ", ")))
                    """
            )
        )
    }

    public func createRadialGradient() -> Widget {
        Box()
    }

    public func updateRadialGradient(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! Box

        let stops = cssStops(gradient: gradient.gradient, environment: environment)

        widget.css.set(
            property: .init(
                key: "background",
                value: """
                    radial-gradient(\
                    circle at \(gradient.center.x * 100)% \(gradient.center.y * 100)%, \
                    \(stops.joined(separator: ", ")))
                    """
            )
        )
    }

    public func createAngularGradient() -> Widget {
        Box()
    }

    public func updateAngularGradient(
        _ widget: Widget,
        gradient: AngularGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! Box

        let adjustedStops = gradient.adjustedStops

        let stops = adjustedStops.map {
            let resolved = $0.color.resolve(in: environment)
            let red = resolved.red * 255
            let green = resolved.green * 255
            let blue = resolved.blue * 255
            return
                """
                rgba(\(red), \(green), \(blue), \
                \(resolved.opacity)) \($0.location * 360)deg
                """
        }

        widget.css.set(
            property: .init(
                key: "background",
                value: """
                    conic-gradient(from \(gradient.startAngle.degrees + 90)deg \
                    at \(gradient.center.x * 100)% \(gradient.center.y * 100)%, \
                    \(stops.joined(separator: ", ")))
                    """
            )
        )
    }

    private func cssStops(gradient: Gradient, environment: EnvironmentValues) -> [String] {
        return gradient.stops.map {
            let resolved = $0.color.resolve(in: environment)
            let red = resolved.red * 255
            let green = resolved.green * 255
            let blue = resolved.blue * 255
            return
                """
                rgba(\(red), \(green), \(blue), \
                \(resolved.opacity)) \($0.location * 100)%
                """
        }
    }
}
