import SwiftJava
import AndroidKit

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomRadialGradient",
    extends: AndroidKit.RadialGradient.self
)
class CustomRadialGradient: AndroidKit.RadialGradient {
    @JavaMethod
    @_nonoverride convenience init(
        _ centerX: Float,
        _ centerY: Float,
        _ radius: Float,
        _ colors: [Int32],
        _ stops: [Float],
        _ tileMode: Shader.TileMode?,
        environment: JNIEnvironment? = nil
    )
}
