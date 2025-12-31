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

    /// Allows the backing scale factor to be overridden. Useful for keeping
    /// UI tests consistent across devices.
    ///
    /// Idea from https://github.com/pointfreeco/swift-snapshot-testing/pull/533
    public var backingScaleFactorOverride: CGFloat?

    public override var backingScaleFactor: CGFloat {
        backingScaleFactorOverride ?? super.backingScaleFactor
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

    // MARK: - FocusChain -
    override public var initialFirstResponder: NSView? {
        get {
            guard let responder = super.initialFirstResponder else {
                return nil
            }
            // Doing this in set doesn't work for some reason.
            // set gets called first, sets the value but its nil for the get
            // directly after. Doing it here instead works.
            return findNextAllowedFocusTarget(suggestion: responder)
        }
        set {
            super.initialFirstResponder = newValue
        }
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

    private func findNextAllowedFocusTarget(
        suggestion: NSView,
        forward: Bool = true
    ) -> NSView? {
        var currentOption: NSView? = suggestion
        while let next = currentOption {
            if !isDescendantOfDisabledParent(next),
                next.canBecomeKeyView,
                !next.isHidden
            {
                return next
            }

            if forward {
                if let cached = forwardFocusChainBypassCache.object(forKey: next) {
                    return cached
                }

                currentOption = next.nextValidKeyView
            } else {
                if let cached = reverseFocusChainBypassCache.object(forKey: next) {
                    return cached
                }

                currentOption = next.previousValidKeyView
            }

            if currentOption == suggestion {
                break
            }
        }

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

    @inline(__always)
    private func addLinkToFocusChainCache(_ result: NSView, following view: NSView) {
        forwardFocusChainBypassCache.setObject(result, forKey: view)
        reverseFocusChainBypassCache.setObject(view, forKey: result)
    }

    override public func selectKeyView(following view: NSView) {
        if let cached = forwardFocusChainBypassCache.object(forKey: view),
            cached.canBecomeKeyView
        {
            makeFirstResponder(cached)
            return
        }

        guard
            let next = view.nextValidKeyView,
            let result = findNextAllowedFocusTarget(suggestion: next)
        else { return }
        makeFirstResponder(result)
        addLinkToFocusChainCache(result, following: view)
    }

    override public func selectKeyView(preceding view: NSView) {
        if let cached = reverseFocusChainBypassCache.object(forKey: view),
            cached.canBecomeKeyView
        {
            makeFirstResponder(cached)
            return
        }

        guard
            let previous = view.previousValidKeyView,
            let result = findNextAllowedFocusTarget(
                suggestion: previous,
                forward: false
            )
        else { return }
        makeFirstResponder(result)
        addLinkToFocusChainCache(view, following: result)
    }

    override public func recalculateKeyViewLoop() {
        invalidateCache()
        super.recalculateKeyViewLoop()

    }
}
