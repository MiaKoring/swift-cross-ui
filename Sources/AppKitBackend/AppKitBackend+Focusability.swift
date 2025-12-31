import AppKit
import SwiftCrossUI

// MARK: - Focusability
final class FocusabilityContainer: NSView {
    private(set) var focusability: SwiftCrossUI.Focusability = .unmodified

    func setFocusability(_ newValue: SwiftCrossUI.Focusability) -> Bool {
        defer { self.focusability = newValue }

        guard
            self.focusability != newValue,
            let window = window as? NSCustomWindow
        else { return false }

        window.invalidateCache()

        return true
    }

    override var canBecomeKeyView: Bool {
        focusability == .enabled
    }

    override var acceptsFirstResponder: Bool {
        focusability == .enabled
    }

    override var focusRingType: NSFocusRingType {
        get {
            .exterior
        }
        set {}
    }

    override func drawFocusRingMask() {
        // Get child's frame in parent coordinates
        let childRect = subviews[0].frame
        NSBezierPath(rect: childRect).fill()
    }

    override var focusRingMaskBounds: NSRect {
        subviews[0].frame
    }

    override func becomeFirstResponder() -> Bool {
        setKeyboardFocusRingNeedsDisplay(subviews[0].frame)

        let result = super.becomeFirstResponder()
        return result
    }

    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        return result
    }
}

extension AppKitBackend {
    public func resignFirstResponder(as widget: NSView) {
        widget.resignFirstResponder()
    }

    public func requestFirstResponder(as widget: NSView) -> Bool {
        widget.becomeFirstResponder()
    }

    public func registerFocusObservers(
        _ data: [FocusData],
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

    public func updateFocusContainer(
        _ widget: NSView,
        focusability: Focusability
    ) -> ObjectIdentifier? {
        let container = widget as! FocusabilityContainer
        if container.setFocusability(focusability),
            let window = container.window
        {
            return ObjectIdentifier(window)
        }
        return nil
    }
}

// MARK: - FocusState

class FocusStateManager: NSObject {
    private var focusData = [ObjectIdentifier: Set<FocusData>]()
    private var lastFocused: NSResponder? = nil
    var shouldSkip: Bool = false

    func register(_ data: [FocusData], for widget: NSView) {
        focusData[ObjectIdentifier(widget)] = Set(data)
    }

    override func observeValue(
        forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let window = object as? NSCustomWindow else {
            return
        }

        if let responder = window.firstResponder,
            !(responder is NSCustomWindow)
        {
            print(responder)
            if responder is NSObservableTextField {
                print("observable tf")
                shouldSkip = true
                self.lastFocused = responder
            } else if !shouldSkip {
                if let lastFocused {
                    print(lastFocused)
                    handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
                }
                self.lastFocused = responder
            } else if shouldSkip {
                print("skipped")
                shouldSkip = false
            }
            let identifier = ObjectIdentifier(responder)
            handleFocusChange(of: identifier, toState: true)
        } else if let lastFocused {
            handleFocusChange(of: ObjectIdentifier(lastFocused), toState: false)
            self.lastFocused = nil
        }
    }

    private func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else {
            return
        }
        if isFocused {
            data.forEach { binding in
                binding.set()
            }
            print("set")
        } else {
            data.forEach { binding in
                binding.reset()
            }
            print("should reset")
        }
    }
}
