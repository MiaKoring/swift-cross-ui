//
//  FocusData.swift
//  swift-cross-ui
//
//  Created by Mia Koring on 31.12.25.
//

public struct FocusData {
    let type: any Hashable.Type
    private let match: any Hashable
    public let set: () -> Void
    public let reset: () -> Void

    public init(
        type: any Hashable.Type, match: any Hashable, set: @escaping () -> Void,
        reset: @escaping () -> Void
    ) {
        self.type = type
        self.match = match
        self.set = set
        self.reset = reset
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
