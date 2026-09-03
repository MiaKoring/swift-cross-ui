import AppKit
import SwiftCrossUI

/// Creates a marker container, keeping focus from entering any of the subviews
/// when `FocusabilityContainer/focusability` is `Focusability.disabled`.
final class FocusabilityContainer: NSView, SwiftCrossUI.FocusabilityContainer {
    var focusability: SwiftCrossUI.Focusability = .unmodified
}

extension AppKitBackend {
    public func registerFocusObservers(
        _ data: [WidgetFocusObserver],
        on widget: NSView
    ) {
        guard widget.acceptsFirstResponder else { return }

        focusManager.register(data, for: widget)
    }

    public func createFocusContainer() -> NSView {
        let container = FocusabilityContainer()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    public func setFocus(of widget: NSView, to focus: Focus) {
        if
            focus == .focused,
            !widget.isHidden,
            widget.acceptsFirstResponder,
            // AppKit passes first responder from NSTextField/NSSecureTextField to an
            // inner NSTextView/NSText.
            // This means when it looks to us like the NSTextField is focused,
            // the NSTextView is the actual first responder.
            // Giving focus back to the surrounding field leads to weird input bugs
            // This makes sure first responder is only given to the widget if it's
            // not the inner NSTextView having focus.
            !textFieldsTextViewIsFocused(field: widget)
        {
            widget.window?.makeFirstResponder(widget)
        }
        
        if
            focus == .unfocused,
            let window = widget.window,
            window.firstResponder == widget || textFieldsTextViewIsFocused(field: widget)
        {
            _ = window.makeFirstResponder(nil)
            return
        }
    }
    
    private func textFieldsTextViewIsFocused(field: NSView) -> Bool {
        if let field = field as? NSTextField {
            return field.currentEditor() === field.window?.firstResponder
        }
        if let field = field as? NSSecureTextField {
            return field.currentEditor() === field.window?.firstResponder
        }
        return false
    }
    
    public func updateFocusContainer(
        _ widget: NSView,
        focusability: Focusability
    ) {
        let container = widget as! FocusabilityContainer
        container.focusability = focusability
    }

    public func setFocusEffectDisabled(on widget: NSView, disabled: Bool) {
        widget.focusRingType = disabled ? .none : .default
    }
}

@MainActor
class FocusStateManager: NSObject {
    private var focusData = [ObjectIdentifier: [WidgetFocusObserver]]()
    private struct WindowFocusState {
        var lastFocused: NSResponder?
        var shouldSkip = false
    }
    private var windowFocusStates = [ObjectIdentifier: WindowFocusState]()

    func register(_ data: [WidgetFocusObserver], for widget: NSView) {
        focusData[ObjectIdentifier(widget)] = data
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let window = object as? NSCustomWindow else { return }
        var windowFocusState = windowFocusStates[ObjectIdentifier(window)] ?? WindowFocusState()
        defer { windowFocusStates[ObjectIdentifier(window)] = windowFocusState }

        // NSObservableTextField and NSObservableSecureTextField give focus
        // to a different view immediately after gaining focus.
        // If the inner View gaining focus isn't skipped, the FocusState would
        // reset to unfocused right after gaining, even though it is focused on screen.
        //
        // Everytime a new view gains focused, the previous one needs it'^s
        // FocusState set to false, because they could use different FocusStates.

        if let responder = window.firstResponder, !(responder is NSCustomWindow) {
            if responder is NSObservableTextField || responder is NSObservableSecureTextField {
                windowFocusState.shouldSkip = true
                if let lastFocused = windowFocusState.lastFocused {
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                windowFocusState.lastFocused = responder
            } else if !windowFocusState.shouldSkip {
                if let lastFocused = windowFocusState.lastFocused {
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                windowFocusState.lastFocused = responder
            } else if windowFocusState.shouldSkip {
                // Exit early to swallow call by the inner target of a FooTextField,
                // that automatically gains focus after the outer widget,
                // which we know, gains focus.
                windowFocusState.shouldSkip = false
                return
            }

            let identifier = ObjectIdentifier(responder)
            handleFocusChange(of: identifier, toState: true)
        } else if let lastFocused = windowFocusState.lastFocused {
            handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
            windowFocusState.lastFocused = nil
        }
    }

    private func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else { return }

        if isFocused {
            data.forEach { binding in
                binding.didGainFocus()
            }
        } else {
            data.forEach { binding in
                binding.didLoseFocus()
            }
        }
    }
}
