import AndroidKit
import SwiftCrossUI

extension AndroidBackend:
    BackendFeatures.TapGestures,
    BackendFeatures.HoverGestures
{
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        child
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        switch gesture.kind {
            case .primary:
                if environment.isEnabled {
                    tapGestureTarget.setOnClickListener(
                        ViewOnClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnClickListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnClickListener(nil)
                }
            case .secondary:
                if environment.isEnabled {
                    tapGestureTarget.setOnTouchListener(
                        SecondaryClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnTouchListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnTouchListener(nil)
                }
            case .longPress:
                if environment.isEnabled {
                    tapGestureTarget.setOnLongClickListener(
                        ViewOnLongClickListener(action: action, environment: Self.env)
                            .as(AndroidKit.View.OnLongClickListener.self)!
                    )
                } else {
                    tapGestureTarget.setOnLongClickListener(nil)
                }
        }
    }
    
    public func createHoverTarget(wrapping child: Widget) -> Widget {
        child
    }
    
    public func updateHoverTarget(
        _ hoverTarget: Widget,
        environment: EnvironmentValues,
        action: @escaping (Bool) -> Void
    ) {
        hoverTarget.setOnHoverListener(
            ViewOnHoverListener(
                enterAction: { action(true) },
                leaveAction: { action(false) },
                environment: Self.env
            )
            .as(AndroidKit.View.OnHoverListener.self)!
        )
    }
}
