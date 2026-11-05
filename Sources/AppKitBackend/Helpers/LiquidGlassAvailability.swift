import AppKit

/// True if we have liquid glass available and enabled.
func hasLiquidGlass() -> Bool {
    // Can't have liquid glass unless we're in macOS 26+
    if #unavailable(macOS 26.0) {
        return false
    }
    
    // On macOS 27+ liquid glass is always used.
    if #available(macOS 27.0, *) {
        return true
    }
    
    let infoDictionary = Bundle.main.infoDictionary
    
    // If we're on macOS 26 and UIDesignRequiresCompatibility is set to true,
    // we don't use liquid glass. macOS 27 and later don't support this key anymore.
    if
        let requiresCompatibility = infoDictionary?["UIDesignRequiresCompatibility"] as? Bool,
        requiresCompatibility
    {
        return false
    }
    
    // Default can be found here:
    // https://developer.apple.com/documentation/bundleresources/information-property-list/lsminimumsystemversion
    let minVersion = infoDictionary?["LSMinimumSystemVersion"] as? String ?? "10.0.0"
    let majorVersion = Int(minVersion.split(separator: ".")[0])!
    
    // If the app is running on macOS but its min deployment target is lower,
    // it doesn't build with liquid glass.
    if majorVersion < 26 {
       return false
    }
    
    // If we aren't running SDK 26.0 or later then we definitely
    // do not have liquid glass.
    guard let sdkName = infoDictionary?["DTSDKName"] as? String else {
        // If we don't have this, we assume we're built against the latest
        // since we're on macOS 26+
        return true
    }
    
    // If the SDK doesn't start with macosx then we just assume we
    // have it because we already verified we're on macOS above.
    guard sdkName.hasPrefix("macosx") else {
        return true
    }
    
    // The SDK version must be at least 26
    let versionString = String(sdkName.dropFirst("macosx".count))
    let major: Int?
    if let dotIndex = versionString.firstIndex(of: ".") {
        major = Int(String(versionString[..<dotIndex]))
    } else {
        major = Int(versionString)
    }
    guard let major else { return true }
    
    return major >= 26
}

enum LiquidGlassAvailability {
    /// Whether liquid glass is used in this app.
    static let isAvailable: Bool = hasLiquidGlass()
}
