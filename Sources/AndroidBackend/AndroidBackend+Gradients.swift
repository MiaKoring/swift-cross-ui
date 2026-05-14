import SwiftCrossUI
import AndroidKit
import AndroidGraphics

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.LinearGradients {
    public func createLinearGradientWidget() -> Widget {
        return createPathWidget()
    }

    public func updateLinearGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.LinearGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let scuiPath = SwiftCrossUI.Rectangle().path(in: .init(origin: .zero, size: .init(Double(size.x), Double(size.y))))
        let path = createPath()

        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let density = widget.getResources().getDisplayMetrics().density

        let count = gradient.gradient.stops.count
        var stops = [Float]()
        var colors = [Int32]()
        stops.reserveCapacity(count)
        colors.reserveCapacity(count)

        for stop in gradient.gradient.stops {
            stops.append(Float(stop.location))
            colors.append(stop.color.resolve(in: environment).asColorInt())
        }

        let pxWidth = Float(size.x) * density
        let pxHeight = Float(size.y) * density

        let gradient = AndroidGraphics.LinearGradient(
            Float(gradient.startPoint.x) * pxWidth,
            Float(gradient.startPoint.y) * pxHeight,
            Float(gradient.endPoint.x) * pxWidth,
            Float(gradient.endPoint.y) * pxHeight,
            colors,
            stops,
            tileClass.CLAMP,
            environment: Self.env
        )

        path.fillPaint.setShader(gradient)

        updatePath(
            path,
            scuiPath,
            bounds: .init(origin: .zero, size: .init(x: Double(size.x), y: Double(size.y))),
            pointsChanged: true,
            environment: environment
        )

        setSize(of: widget, to: size)

        widget.as(PathView.self)!.set(
            path: path.path,
            fillPaint: path.fillPaint,
            strokePaint: path.strokePaint
        )
    }
}
