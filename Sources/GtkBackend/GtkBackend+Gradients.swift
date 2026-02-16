import Gtk
import SwiftCrossUI
import CGtk

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
        
        let radians = Self.angle(from: startPoint, to: endPoint)
        
        let stops = gradient.gradient.stops.map {
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
        
        widget.css.set(property: .init(
            key: "background",
            value: """
                linear-gradient(\(radians + Self.degrees90asRadians)rad, \(stops.joined(separator: ", ")))
                """
        ))
        
        print("----")
        print(startPoint)
        print(endPoint)
        print(gradient.startPoint)
        print(gradient.endPoint)
        print(Angle(radians: radians + Self.degrees90asRadians).degrees)
    }

    /// Returns the angle radians
    static func angle(from start: UnitPoint, to end: UnitPoint) -> Double {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        
        return atan2(deltaY, deltaX)
    }
    
    static let degrees90asRadians = Double.pi / 2
}
