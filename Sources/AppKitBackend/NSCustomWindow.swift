import AppKit
import SwiftCrossUI

public class NSCustomWindow: NSWindow {
    var customDelegate = Delegate()
    var persistentUndoManager = UndoManager()

    var startupHappened: Bool? = nil
    var shouldPassthroughFocusRequests: Bool = false

    /// A reference to the sheet currently presented on top of this window, if any.
    /// If the sheet itself has another sheet presented on top of it, then that doubly
    /// nested sheet gets stored as the sheet's nestedSheet, and so on.
    var nestedSheet: NSCustomSheet?

    override public var firstResponder: NSResponder? {
        super.firstResponder
    }

    /// Allows the backing scale factor to be overridden. Useful for keeping
    /// UI tests consistent across devices.
    ///
    /// Idea from https://github.com/pointfreeco/swift-snapshot-testing/pull/533
    public var backingScaleFactorOverride: CGFloat?

    public override var backingScaleFactor: CGFloat {
        backingScaleFactorOverride ?? super.backingScaleFactor
    }

    private var forwardFocusChainBypassCache = NSMapTable<NSResponder, NSView>(
        keyOptions: .weakMemory, valueOptions: .weakMemory
    )

    private var reverseFocusChainBypassCache = NSMapTable<NSResponder, NSView>(
        keyOptions: .weakMemory, valueOptions: .weakMemory
    )

    @inline(__always)
    func removeFromBypassCache(_ view: NSResponder) {
        if let result = forwardFocusChainBypassCache.object(forKey: view) {
            reverseFocusChainBypassCache.removeObject(forKey: result)
        }
        forwardFocusChainBypassCache.removeObject(forKey: view)
    }

    func removeFromBypassCache(_ views: [NSResponder]) {
        for view in views {
            removeFromBypassCache(view)
        }
    }

    func invalidateCache() {
        forwardFocusChainBypassCache = NSMapTable<NSResponder, NSView>(
            keyOptions: .weakMemory, valueOptions: .weakMemory
        )
        reverseFocusChainBypassCache = NSMapTable<NSResponder, NSView>(
            keyOptions: .weakMemory, valueOptions: .weakMemory
        )
    }

    override public func selectKeyView(following view: NSView) {
        if let cached = forwardFocusChainBypassCache.object(forKey: view),
            cached.canBecomeKeyView
        {
            //print("cache used: \(cached)")
            makeFirstResponder(cached)
            return
        }

        guard
            let next = view.nextValidKeyView,
            let result = findNextAllowedFocusTarget(suggestion: next)
        else { return }

        makeFirstResponder(result)

        forwardFocusChainBypassCache.setObject(result, forKey: view)
        reverseFocusChainBypassCache.setObject(view, forKey: result)
    }

    private func findNextAllowedFocusTarget(
        suggestion: NSView
    ) -> NSView? {
        var currentOption: NSView? = suggestion
        while let next = currentOption {
            if !isDescendantOfDisabledParent(next),
                next.canBecomeKeyView,
                !next.isHidden
            {
                return next
            }

            if let cached = forwardFocusChainBypassCache.object(forKey: next) {
                //print("cache used")
                return cached
            }
            currentOption = next.nextValidKeyView
            if currentOption == suggestion {
                break
            }
        }
        //print("couldn't find result \(suggestion)")
        return nil
    }

    @inline(__always)
    private func isDescendantOfDisabledParent(_ view: NSView) -> Bool {
        var current = view.superview

        while let next = current {
            if let next = next as? FocusabilityContainer,
                next.focusability == .disabled
            {
                return true
            }
            current = next.superview
        }

        return false
    }

    override public func selectKeyView(preceding view: NSView) {
        if let previous = view.previousValidKeyView {
            makeFirstResponder(previous)
        }
        //super.selectKeyView(preceding: view)
        //print("called selectKeyView preceding \(view)")
        return
        guard !shouldPassthroughFocusRequests else {
            //print("passthrough")
            super.selectKeyView(preceding: view)
            return
        }
    }

    //https://developer.apple.com/documentation/appkit/nswindow/selectpreviouskeyview(_:)
    override public func selectPreviousKeyView(_ sender: Any?) {
        super.selectPreviousKeyView(sender)
        //print("called selectPreviousKeyView")
    }

    override public func selectNextKeyView(_ sender: Any?) {
        //print("called selectNextKeyView")
        //print(sender)

        return super.selectNextKeyView(sender)

        if let sender = sender as? Self {
            if self.initialFirstResponder?.canBecomeKeyView == true {
                self.initialFirstResponder?.becomeFirstResponder()
            } else {
                self.initialFirstResponder?.nextKeyView?.becomeFirstResponder()
            }
            return
        }

        if let sender = sender as? NSView {
            //print("sender is NSView: \(sender)")
            sender.nextKeyView?.becomeFirstResponder()
        }
    }

    override public func recalculateKeyViewLoop() {
        invalidateCache()
        print("key loop recalc requested")
        super.recalculateKeyViewLoop()

    }

    class Delegate: NSObject, NSWindowDelegate {
        var resizeHandler: ((SIMD2<Int>) -> Void)?

        func setHandler(_ resizeHandler: @escaping (SIMD2<Int>) -> Void) {
            self.resizeHandler = resizeHandler
        }

        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            guard let resizeHandler else {
                return frameSize
            }

            let contentSize = sender.contentRect(
                forFrameRect: NSRect(
                    x: sender.frame.origin.x, y: sender.frame.origin.y, width: frameSize.width,
                    height: frameSize.height)
            )

            resizeHandler(
                SIMD2(
                    Int(contentSize.width.rounded(.towardZero)),
                    Int(contentSize.height.rounded(.towardZero))
                )
            )

            return frameSize
        }

        func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
            (window as! NSCustomWindow).persistentUndoManager
        }
    }
}
