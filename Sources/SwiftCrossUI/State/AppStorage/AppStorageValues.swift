public struct AppStorageValues {
    private let __provider: AppStorageProvider?

    /// Only to be used by AppStorage
    internal init(__provider: AppStorageProvider?) {
        self.__provider = __provider
    }

    public func __getValue<T: Codable & Sendable>(_ key: any AppStorageKey<T>.Type) -> T {
        guard let __provider else { return key.defaultValue }
        return __provider.getValue(key: key.name, defaultValue: key.defaultValue)
    }

    public func __setValue<T: Codable & Sendable>(_ key: any AppStorageKey<T>.Type, newValue: T) {
        __provider?.setValue(key: key.name, newValue: newValue)
    }
}
