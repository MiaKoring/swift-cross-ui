public struct FocusData {
    let type: any Hashable.Type
    private let match: any Hashable
    public let set: () -> Void
    public let reset: () -> Void

    public let shouldUnfocus: Bool
    public let matches: Bool

    public init(
        type: any Hashable.Type,
        match: any Hashable,
        set: @escaping () -> Void,
        reset: @escaping () -> Void,
        matches: Bool,
        shouldUnfocus: Bool
    ) {
        self.type = type
        self.match = match
        self.set = set
        self.reset = reset
        self.matches = matches
        self.shouldUnfocus = shouldUnfocus
    }
}

extension FocusData: Hashable {
    public static func == (lhs: FocusData, rhs: FocusData) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type).hashValue)
        hasher.combine(match)
    }
}
