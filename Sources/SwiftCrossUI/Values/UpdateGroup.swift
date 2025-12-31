//
//  UpdateGroup.swift
//  swift-cross-ui
//
//  Created by Mia Koring on 31.12.25.
//

@MainActor
public class UpdateGroup {
    // Tracks the amount of entries and leaves
    // to know when an update cycle ends.
    private var depth: UInt32 = 0

    private var registeredCallbacks = [AnyHashable: (@escaping () -> ViewLayoutResult?) -> Void]()

    /// Needs to be called at the entry of each
    /// ``ViewGraphNode/update`` and ``ViewGraphNode/bottomUpUpdate``
    public func enter() {
        depth += 1
    }

    /// Needs to be called at the exit of each
    /// ``ViewGraphNode/update`` and ``ViewGraphNode/bottomUpUpdate``

    // A closure is passed instead of ViewUpdateResult
    // as ViewUpdateResult is comparatively heavy.
    // The closure provides access to ``ViewUpdateResult`` to callbacks if needed
    // while avoiding to pass a copy every time leave is called.
    // The closure overhead is expected to be smaller.
    public func leave(
        getResult: @escaping () -> ViewLayoutResult?
    ) {
        precondition(
            depth > 0,
            Self.preconditionErrorMessage
        )

        guard depth == 1 else {
            depth -= 1
            return
        }
        defer { depth = 0 }

        registeredCallbacks.values.forEach { block in
            block(getResult)
        }
    }

    /// Registers a callback to be executed after the completion of a view update cycle
    public func registerUpdateFinishedCallback(
        for identifier: any Hashable,
        run block: @escaping (@escaping () -> ViewLayoutResult?) -> Void
    ) {
        registeredCallbacks[AnyHashable(identifier)] = block
    }

    /// Removes the callback for a given identifier.
    public func removeUpdateFinishedCallback(
        for identifier: any Hashable
    ) {
        registeredCallbacks[AnyHashable(identifier)] = nil
    }

    public init() {}

    // The message to be provided as reason for the crash
    // occuring when more leaves than entries happen
    private static let preconditionErrorMessage = """
        'UpdateGroup.leave()' got called more often than 'UpdateGroup.enter()'. \
        Every 'ViewGraphNode' is required to enter as soon as its update function is \
        called and to leave on scope exit. \
        Do not use anywhere else. \
        An even number of entries and leaves is crucial to function correctly.
        """
}
