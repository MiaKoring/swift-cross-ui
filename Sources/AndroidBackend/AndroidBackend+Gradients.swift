import SwiftCrossUI
import AndroidKit
import AndroidGraphics

// swiftlint:disable force_try
extension AndroidBackend: BackendFeatures.Gradients {
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

        let density = Float(environment.windowScaleFactor)

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

        _ = path.fillPaint.setShader(gradient)

        updatePath(
            path,
            scuiPath,
            bounds: .init(origin: .zero, size: .init(x: Double(size.x), y: Double(size.y))),
            pointsChanged: true,
            environment: environment
        )

        widget.as(PathView.self)!.set(
            path: path.path,
            fillPaint: path.fillPaint,
            strokePaint: path.strokePaint
        )
    }

    public func createRadialGradientWidget() -> Widget {
        return createPathWidget()
    }

    public func updateRadialGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.RadialGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let scuiPath = SwiftCrossUI.Rectangle().path(in: .init(origin: .zero, size: .init(Double(size.x), Double(size.y))))
        let path = createPath()

        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let density = Float(environment.windowScaleFactor)

        let count = gradient.gradient.stops.count
        var stops = [Float]()
        var colors = [Int32]()
        stops.reserveCapacity(count)
        colors.reserveCapacity(count)

        for stop in gradient.adjustedStops {
            stops.append(Float(stop.location))
            colors.append(stop.color.resolve(in: environment).asColorInt())
        }

        let pxWidth = Float(size.x) * density
        let pxHeight = Float(size.y) * density

        let centerX = Float(gradient.center.x) * pxWidth
        let centerY = Float(gradient.center.y) * pxHeight

        let gradient = CustomRadialGradient(
            centerX,
            centerY,
            Float(max(gradient.endRadius, gradient.startRadius, 1)) * density,
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

        widget.as(PathView.self)!.set(
            path: path.path,
            fillPaint: path.fillPaint,
            strokePaint: path.strokePaint
        )
    }

    public func createAngularGradientWidget() -> Widget {
        return createPathWidget()
    }

    public func updateAngularGradientWidget(
        _ widget: Widget,
        gradient: SwiftCrossUI.AngularGradient,
        withSize size: SIMD2<Int>,
        in environment: EnvironmentValues
    ) {
        let scuiPath = SwiftCrossUI.Rectangle().path(in: .init(origin: .zero, size: .init(Double(size.x), Double(size.y))))
        let path = createPath()

        let tileClass = try! JavaClass<AndroidGraphics.Shader.TileMode>()
        let colorClass = try! JavaClass<AndroidGraphics.Color>()

        let density = Float(environment.windowScaleFactor)

        let count = gradient.gradient.stops.count
        var stops = [Float]()
        var colors = [Int32]()
        stops.reserveCapacity(count)
        colors.reserveCapacity(count)

        for stop in gradient.adjustedStops {
            stops.append(Float(stop.location))
            colors.append(stop.color.resolve(in: environment).asColorInt())
        }

        let pxWidth = Float(size.x) * density
        let pxHeight = Float(size.y) * density

        let centerX = Float(gradient.center.x) * pxWidth
        let centerY = Float(gradient.center.y) * pxHeight

        let startAngleDegrees = Float(gradient.startAngle.degrees)

        let gradient = AndroidGraphics.SweepGradient(
            centerX,
            centerY,
            colors,
            stops,
            environment: Self.env
        )

        let gradientMatrix = AndroidGraphics.Matrix()

        let scaleX: Float = 1.0
        let scaleY: Float = Float(size.y) / Float(size.x)

        gradientMatrix.postRotate(
            startAngleDegrees,
            centerX,
            centerY
        )

        gradientMatrix.postScale(
            scaleX,
            scaleY,
            centerX,
            centerY
        )

        gradient.setLocalMatrix(gradientMatrix)

        _ = path.fillPaint.setShader(gradient)

        updatePath(
            path,
            scuiPath,
            bounds: .init(origin: .zero, size: .init(x: Double(size.x), y: Double(size.y))),
            pointsChanged: true,
            environment: environment
        )

        widget.as(PathView.self)!.set(
            path: path.path,
            fillPaint: path.fillPaint,
            strokePaint: path.strokePaint
        )
    }
}
