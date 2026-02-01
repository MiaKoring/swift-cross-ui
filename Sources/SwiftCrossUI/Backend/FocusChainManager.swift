public protocol FocusChainManager {
    associatedtype Widget: FocusChainParticipant

    func cachedStop(following key: Widget) -> Widget?
    func cachedStop(preceding key: Widget) -> Widget?

    func closestValidStop(following view: Widget) -> Widget?
    func closestValidStop(preceding view: Widget) -> Widget?

    func setRelationship(_ widget: Widget, following previous: Widget)

    func makeKey(_ widget: Widget)

    @inlinable
    @inline(__always)
    func getParent(of widget: Widget) -> Widget?
}

public protocol FocusabilityContainer {
    var focusability: Focusability { get }
}

public protocol FocusChainParticipant: Equatable {
    var canBeTabStop: Bool { get }
    var isHidden: Bool { get }
}

extension FocusChainManager {
    public func findNextAllowedFocusTarget(
        suggestion: Widget,
        forward: Bool = true
    ) -> Widget? {
        var currentOption: Widget? = suggestion
        while let next = currentOption {
            if !isDescendantOfDisabledParent(next),
                next.canBeTabStop,
                !next.isHidden
            {
                return next
            }

            if forward {
                if let cached = cachedStop(following: next) {
                    return cached
                }

                currentOption = closestValidStop(following: next)
            } else {
                if let cached = cachedStop(preceding: next) {
                    return cached
                }

                currentOption = closestValidStop(preceding: next)
            }

            if currentOption == suggestion {
                break
            }
        }

        return nil
    }

    @inline(__always)
    private func isDescendantOfDisabledParent(_ widget: Widget) -> Bool {
        var current = getParent(of: widget)

        while let next = current {
            if let next = next as? FocusabilityContainer,
                next.focusability == .disabled
            {
                return true
            }
            current = getParent(of: next)
        }

        return false
    }

    public func selectTabStop(following widget: Widget) {
        if let cached = cachedStop(following: widget),
            cached.canBeTabStop
        {
            logger.info("used following cache for \(widget)")
            makeKey(cached)
            return
        }

        guard
            let next = closestValidStop(following: widget),
            let result = findNextAllowedFocusTarget(suggestion: next)
        else { return }

        logger.info("found next: \(next)")
        logger.info("\ncurrent: \(widget)\nnext:\(next)")

        makeKey(result)
        setRelationship(result, following: widget)
    }

    public func selectTabStop(preceding widget: Widget) {
        if let cached = cachedStop(preceding: widget),
            cached.canBeTabStop
        {
            logger.info("used previous cache for \(widget)")
            makeKey(cached)
            return
        }
        guard
            let previous = closestValidStop(preceding: widget),
            let result = findNextAllowedFocusTarget(
                suggestion: previous,
                forward: false
            )
        else { return }
        logger.info("found previous: \(previous)")
        logger.info("\ncurrent: \(widget)\nprevious:\(previous)")

        makeKey(result)
        setRelationship(widget, following: result)
    }
}
