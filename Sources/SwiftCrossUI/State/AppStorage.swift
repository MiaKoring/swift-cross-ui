import Foundation
import Mutex

private let appStorageCache: Mutex<[String: any Codable & Sendable]> = Mutex([:])
private let appStoragePublisherCache: Mutex<[String: Publisher]> = Mutex([:])

/// Like ``State``, but persists its value to disk so that it survives betweeen
/// app launches.
@propertyWrapper
public struct AppStorage<Value: Codable & Sendable>: ObservableProperty {
    // TODO: Observe changes to persisted values made by external processes

    private final class Storage: StateStorageProtocol {
        let mode: Mode
        var downstreamObservation: Cancellable?
        var provider: (any AppStorageProvider)?

        init(mode: Mode) {
            self.mode = mode
        }

        lazy var didChange: Publisher = {
            appStoragePublisherCache.withLock { cache in
                let cacheKey = mode.pathDescription
                guard let publisher = cache[cacheKey] else {
                    let newPublisher = Publisher()
                    cache[cacheKey] = newPublisher
                    return newPublisher
                }
                return publisher
            }
        }()

        var value: Value {
            get {
                switch mode {
                    case .key(let key, let defaultValue):
                        guard let provider else {
                            // NB: We used to call `fatalError` here, but since `StateImpl` accesses this
                            // property on initialization, we're returning the default value instead.
                            return defaultValue
                        }
                        return provider.getValue(key: key, defaultValue: defaultValue)
                    case .path(let keyPath):
                        return AppStorageValues(__provider: provider)[keyPath: keyPath]
                }
            }

            set {
                guard let provider else {
                    fatalError(
                        """
                        @AppStorage value with key '\(mode.pathDescription)' used before initialization. \
                        Don't use @AppStorage properties before SwiftCrossUI requests the \
                        body of the enclosing 'App' or 'View'.
                        """
                    )
                }
                switch mode {
                    case .key(let key, _):
                        provider.setValue(key: key, newValue: newValue)
                    case .path(let keyPath):
                        var values = AppStorageValues(__provider: provider)
                        values[keyPath: keyPath] = newValue
                }

            }
        }
    }

    private let implementation: StateImpl<Storage>
    private var storage: Storage { implementation.storage }

    public var didChange: Publisher { storage.didChange }

    public var wrappedValue: Value {
        get { implementation.wrappedValue }
        nonmutating set { implementation.wrappedValue = newValue }
    }

    public var projectedValue: Binding<Value> { implementation.projectedValue }

    public init(wrappedValue defaultValue: Value, _ key: String) {
        implementation = StateImpl(initialStorage: Storage(mode: .key(key, defaultValue)))
    }

    public init(_ key: String) where Value: ExpressibleByNilLiteral {
        self.init(wrappedValue: nil, key)
    }

    public func update(with environment: EnvironmentValues, previousValue: AppStorage<Value>?) {
        implementation.update(with: environment, previousValue: previousValue?.implementation)
        storage.provider = environment.appStorageProvider
    }

    enum Mode {
        case key(String, Value)
        case path(WritableKeyPath<AppStorageValues, Value>)

        var pathDescription: String {
            switch self {
                case .key(let key, _):
                    key
                case .path(let keyPath):
                    "\(keyPath)"
            }
        }
    }
}

extension AppStorage {
    @available(
        *, deprecated,
        message: "'AppStorage' does not work correctly with classes; use a struct instead"
    )
    public init(wrappedValue defaultValue: Value, _ key: String) where Value: AnyObject {
        implementation = StateImpl(initialStorage: Storage(mode: .key(key, defaultValue)))
    }

    @available(
        *, deprecated,
        message: """
            'AppStorage' currently does not persist 'ObservableObject' types \
            to disk when published properties update
            """
    )

    public init(wrappedValue defaultValue: Value, _ key: String) where Value: ObservableObject {
        implementation = StateImpl(initialStorage: Storage(mode: .key(key, defaultValue)))
    }
}

// MARK: - AppStorageKey

extension AppStorage {
    public init<Key: AppStorageKey<Value>>(_: Key.Type) {
        self.init(wrappedValue: Key.defaultValue, Key.name)
    }

    public init(_ keyPath: WritableKeyPath<AppStorageValues, Value>) {
        implementation = StateImpl(initialStorage: Storage(mode: .path(keyPath)))
    }
}

// MARK: - AppStorageProviderExtension
extension AppStorageProvider {
    public func getValue<T: Codable>(key: String, defaultValue: T) -> T {
        return appStorageCache.withLock { cache in
            // If this is the very first time we're reading from this key, it won't
            // be in the cache yet. In that case, we return the already-persisted value
            // if it exists, or the default value otherwise; either way, we add it to the
            // cache so subsequent accesses of `value` won't have to read from disk again.
            guard let cachedValue = cache[key] else {
                let value =
                    self.retrieveValue(ofType: T.self, forKey: key) ?? defaultValue
                cache[key] = value
                return value
            }

            // Make sure that we have the right type.
            guard let cachedValue = cachedValue as? T else {
                logger.warning(
                    "'@AppStorage' property is of the wrong type; using default value",
                    metadata: [
                        "key": "\(key)",
                        "providedType": "\(T.self)",
                        "actualType": "\(type(of: cachedValue))",
                    ]
                )
                return defaultValue
            }

            return cachedValue
        }
    }

    public func setValue<T: Codable>(key: String, newValue: T) {
        appStorageCache.withLock { cache in
            cache[key] = newValue
            do {
                logger.trace("persisting '\(newValue)' for '\(key)'")
                try self.persistValue(newValue, forKey: key)
            } catch {
                logger.warning(
                    "failed to encode '@AppStorage' data",
                    metadata: [
                        "value": "\(newValue)",
                        "error": "\(error.localizedDescription)",
                    ]
                )
            }
        }
    }
}

/// A type safe key for ``AppStorage`` properties, similar in spirit
/// to ``EnvironmentKey``.
public protocol AppStorageKey<Value> {
    associatedtype Value: Codable

    /// The name to use when persisting the key.
    static var name: String { get }
    /// The default value for the key.
    static var defaultValue: Value { get }
}

public struct AppStorageValues {
    private let __provider: AppStorageProvider?

    /// Only to be used by AppStorage
    internal init(__provider: AppStorageProvider?) {
        self.__provider = __provider
    }

    public func __getValue<T: Codable>(_ key: AppStorageKey<T>.Type) -> T {
        guard let __provider else { return key.defaultValue }
        return __provider.getValue(key: key.name, defaultValue: key.defaultValue)
    }

    public func __setValue<T: Codable>(_ key: AppStorageKey<T>.Type, newValue: T) {
        __provider?.setValue(key: key.name, newValue: newValue)
    }
}
