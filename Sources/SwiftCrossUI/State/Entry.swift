/// Creates an environment values, or appstorage values entry.
///
/// Create EnvironmentValues entries by extending the EnvironmentValues structure with new properties and attaching the @Entry macro to the variable declarations:
/// ```swift
/// extension EnvironmentValues {
///     @Entry var myCustomValue: String = "Default value"
///     @Entry var anotherCustomValue = true
/// }
/// ```
///
/// Create AppStorage entries by extending the AppStorageValues structure with new properties and attaching the @Entry macro to the variable declarations:
/// ```swift
/// extension AppStorageValues {
///     @Entry var myCustomValue: String = "Default value"
///     @Entry var anotherCustomValue = true
/// }
/// ```
@attached(accessor) @attached(peer, names: prefixed(__Key_))
public macro Entry() =
    #externalMacro(
        module: "SwiftCrossUIMacrosPlugin",
        type: "EntryMacro"
    )
