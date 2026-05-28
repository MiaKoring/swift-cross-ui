import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.CustomButton",
    extends: AndroidKit.FrameLayout.self
)
class CustomButton: AndroidKit.FrameLayout {
    static let horizontalPadding = 11
    static let verticalPadding = 5
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: Activity?,
        environment: JNIEnvironment? = nil
    )
    
    @JavaMethod
    func set(action: SwiftAction?, buttonType: Int32, isEnabled: Bool)
}
