import AndroidKit
import SwiftJava

@JavaClass(
    "dev.swiftcrossui.androidbackend.ViewOnHoverListener",
    extends: AndroidView.View.OnHoverListener.self
)
class ViewOnHoverListener: JavaObject {
    @JavaMethod
    @_nonoverride convenience init(
        enterAction: SwiftAction?,
        leaveAction: SwiftAction?,
        environment: JNIEnvironment? = nil
    )
}

extension ViewOnHoverListener {
    convenience init(
        enterAction: @escaping () -> (),
        leaveAction: @escaping () -> (),
        environment: JNIEnvironment? = nil
    ) {
        let enterObject = SwiftAction(
            environment: environment,
            action: enterAction
        )
        let leaveObject = SwiftAction(
            environment: environment,
            action: leaveAction
        )
        self.init(
            enterAction: enterObject,
            leaveAction: leaveObject,
            environment: environment
        )
    }
}
