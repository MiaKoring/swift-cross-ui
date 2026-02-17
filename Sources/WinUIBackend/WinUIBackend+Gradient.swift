import SwiftCrossUI
import WinUI
import WindowsFoundation

extension WinUIBackend {
    public func createLinearGradient() -> Widget {
        WinUI.Rectangle()
    }

    public func updateLinearGradient(
        _ widget: Widget,
        gradient: LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let widget = widget as! WinUI.Rectangle

        let collection = GradientStopCollection()

        gradient.gradient.stops.forEach {
            let color = $0.color.resolve(in: environment)
            let stop = GradientStop()
            stop.color = .init(
                a: UInt8(color.opacity * 255),
                r: UInt8(color.red * 255),
                g: UInt8(color.green * 255),
                b: UInt8(color.blue * 255)
            )
            stop.offset = $0.location

            collection.append(stop)
        }

        let brush = LinearGradientBrush()
        brush.startPoint = gradient.startPoint.point
        brush.endPoint = gradient.endPoint.point
        brush.gradientStops = collection

        widget.fill = brush
    }
}

extension UnitPoint {
    var point: WindowsFoundation.Point {
        Point(
            x: Float(x),
            y: Float(y)
        )
    }
}
