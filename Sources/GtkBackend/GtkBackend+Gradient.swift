import CGtk
import Gtk
@_spi(Backends) import SwiftCrossUI
import Foundation

extension GtkBackend {
    public func createLinearGradientWidget() -> Widget {
        DrawingArea()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let drawingArea = widget as! DrawingArea
        
        let firstStop = gradient.gradient.stops.first!
        let lastStop = gradient.gradient.stops.last!
        
        // Start and end point based on size and relative coordinates
        let startPoint = UnitPoint(
            x: Double(size.x) * gradient.startPoint.x,
            y: Double(size.y) * gradient.startPoint.y
        )
        
        var endPoint = UnitPoint(
            x: Double(size.x) * gradient.endPoint.x,
            y: Double(size.y) * gradient.endPoint.y
        )
        
        let adjustedStops = gradient.gradient.adjustedStops
        
        let colors = adjustedStops.map {
            $0.color.resolve(in: environment)
        }
        
        drawingArea.setDrawFunc { [weak self] cairo, _, _ in
            guard let self else { return }
            
            let pattern = cairo_pattern_create_linear(
                startPoint.x,
                startPoint.y,
                endPoint.x,
                endPoint.y
            )
            
            for (index, stop) in adjustedStops.enumerated() {
                let color = colors[index]
                cairo_pattern_add_color_stop_rgba(
                    pattern,
                    stop.location,
                    Double(color.red),
                    Double(color.green),
                    Double(color.blue),
                    Double(color.opacity)
                )
            }
            
            cairo_set_source(cairo, pattern)
            cairo_rectangle(cairo, 0, 0, Double(size.x), Double(size.y))
            cairo_fill(cairo)
            cairo_pattern_destroy(pattern)
        }
    }

    public func createRadialGradientWidget() -> Widget {
        DrawingArea()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let drawingArea = widget as! DrawingArea
        
        let stops = gradient.startRadius < gradient.endRadius
            ? gradient.gradient.adjustedStops
            : invertedStops(stops: gradient.gradient.adjustedStops)
        
        let centerX = gradient.center.x * Double(size.x)
        let centerY = gradient.center.y * Double(size.y)
        
        let colors = stops.map {
            $0.color.resolve(in: environment)
        }
        
        drawingArea.setDrawFunc { [weak self] cairo, _, _ in
            guard let self else { return }
            
            let pattern = cairo_pattern_create_radial(
                centerX,
                centerY,
                gradient.startRadius,
                centerX,
                centerY,
                gradient.endRadius
            )
            
            for (index, stop) in stops.enumerated() {
                let color = colors[index]
                cairo_pattern_add_color_stop_rgba(
                    pattern,
                    stop.location,
                    Double(color.red),
                    Double(color.green),
                    Double(color.blue),
                    Double(color.opacity)
                )
            }
            
            cairo_set_source(cairo, pattern)
            cairo_rectangle(cairo, 0, 0, Double(size.x), Double(size.y))
            cairo_fill(cairo)
            cairo_pattern_destroy(pattern)
        }
    }

    private func invertedStops(stops: [Gradient.Stop]) -> [Gradient.Stop] {
        return stops.reversed().map { stop in
            Gradient.Stop(
                color: stop.color,
                location: 1.0 - stop.location
            )
        }
    }

    private func cssStops(stops: [Gradient.Stop], environment: EnvironmentValues) -> [String] {
        return stops.map { stop in
            let resolved = stop.color.resolve(in: environment)
            let red = resolved.red * 255
            let green = resolved.green * 255
            let blue = resolved.blue * 255
            let location = stop.location * 100

            return
                """
                rgba(\(red), \(green), \(blue), \
                \(resolved.opacity)) \(location)%
                """
        }
    }
}
