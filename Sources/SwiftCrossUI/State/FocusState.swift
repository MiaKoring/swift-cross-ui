//
//  FocusState.swift
//  swift-cross-ui
//
//  Created by Mia Koring on 31.12.25.
//

import Foundation

/// A property wrapper type that can read and write a value that SwiftUI updates as the placement of focus within the scene changes.
@propertyWrapper
public struct FocusState<Value: Hashable>: DynamicProperty, StateProperty {
    class Storage {
        // This inner box is what stays constant between view updates. The
        // outer box (Storage) is used so that we can assign this box to
        // future state instances from the non-mutating
        // `update(with:previousValue:)` method. It's vital that the inner
        // box remains the same so that bindings can be stored across view
        // updates.
        var box: InnerBox

        class InnerBox {
            var value: Value
            var didChange = Publisher()
            var downstreamObservation: Cancellable?

            init(value: Value) {
                self.value = value
            }

            /// Call this to publish an observation to all observers after
            /// setting a new value. This isn't in a didSet property accessor
            /// because we want more granular control over when it does and
            /// doesn't trigger.
            ///
            /// Additionally updates the downstream observation if the
            /// wrapped value is an Optional<some ObservableObject> and the
            /// current case has toggled.
            func postSet() {
                // If the wrapped value is an Optional<some ObservableObject>
                // then we need to observe/unobserve whenever the optional
                // toggles between `.some` and `.none`.
                if let value = value as? OptionalObservableObject {
                    if let innerDidChange = value.didChange, downstreamObservation == nil {
                        downstreamObservation = didChange.link(toUpstream: innerDidChange)
                    } else if value.didChange == nil, let observation = downstreamObservation {
                        observation.cancel()
                        downstreamObservation = nil
                    }
                }
                didChange.send()
            }
        }

        init(_ value: Value) {
            self.box = InnerBox(value: value)
        }
    }

    var storage: Storage

    var didChange: Publisher {
        storage.box.didChange
    }

    public var wrappedValue: Value {
        get {
            storage.box.value
        }
        nonmutating set {
            storage.box.value = newValue
            storage.box.postSet()
        }
    }

    public var projectedValue: FocusState.Binding {
        // Specifically link the binding to the inner box instead of the outer
        // storage which changes with each view update.
        let box = storage.box
        return FocusState.Binding(
            get: {
                box.value
            },
            set: { newValue in
                box.value = newValue
                box.postSet()
            },
            reset: {
                box.value = emptyState
                box.postSet()
            }
        )
    }

    let emptyState: Value

    public init() where Value == Bool {
        storage = Storage(false)
        emptyState = false
    }

    public init<T>() where Value == T?, T: Hashable {
        storage = Storage(nil)
        emptyState = nil
    }

    public func update(with environment: EnvironmentValues, previousValue: FocusState<Value>?) {
        if let previousValue {
            storage.box = previousValue.storage.box
        }
    }

    func tryRestoreFromSnapshot(_ snapshot: Data) {}

    func snapshot() throws -> Data? { nil }

    /// A property wrapper type that can read and write a value that indicates the current focus location.
    @propertyWrapper
    public class Binding {
        public var wrappedValue: Value {
            get {
                getValue()
            }
            set {
                setValue(newValue)
            }
        }

        public var projectedValue: FocusState<Value>.Binding {
            // Just a handy helper so that you can use `@Binding` properties like
            // you would `@State` properties.
            self
        }

        /// The stored getter.
        private let getValue: () -> Value
        /// The stored setter.
        private let setValue: (Value) -> Void

        private let resetValue: () -> Void

        /// Creates a binding with a custom getter and setter. To create a binding from
        /// an `@State` property use its projected value instead: e.g. `$myStateProperty`
        /// will give you a binding for reading and writing `myStateProperty` (assuming that
        /// `myStateProperty` is marked with `@State` at its declaration site).
        public init(
            get: @escaping () -> Value, set: @escaping (Value) -> Void, reset: @escaping () -> Void
        ) {
            self.getValue = get
            self.setValue = set
            self.resetValue = reset
        }

        func reset() {
            resetValue()
        }

        /// Returns a new binding that will perform an action whenever it is used to set
        /// the source of truth's value.
        public func onChange(_ action: @escaping (Value) -> Void) -> FocusState.Binding {
            return FocusState.Binding(
                get: getValue,
                set: { newValue in
                    self.setValue(newValue)
                    action(newValue)
                },
                reset: resetValue
            )
        }
    }

}
