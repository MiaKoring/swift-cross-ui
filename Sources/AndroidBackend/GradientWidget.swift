import SwiftJava
import AndroidKit
import AndroidGraphics

@JavaClass(
    "dev.swiftcrossui.androidbackend.GradientWidget",
    extends: AndroidKit.View.self
)
class GradientWidget: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )
    
    @JavaMethod
    func set(
        width: Float,
        height: Float
    )
    
    @JavaMethod
    func setLinearGradient(
        gradient: AndroidGraphics.LinearGradient?
    )
    
    @JavaMethod
    func setRadialGradient(
        gradient: AndroidGraphics.RadialGradient?
    )
    
    @JavaMethod
    func setSweepGradient(
        gradient: AndroidGraphics.SweepGradient?
    )
}
