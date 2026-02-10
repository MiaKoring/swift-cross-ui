/// A type safe key for ``AppStorage`` properties, similar in spirit
/// to ``EnvironmentKey``.
public protocol AppStorageKey<Value> {
    associatedtype Value: Codable

    /// The name to use when persisting the key.
    static var name: String { get }
    /// The default value for the key.
    static var defaultValue: Value { get }
}
