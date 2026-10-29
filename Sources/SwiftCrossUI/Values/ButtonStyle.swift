/// A type that applies standard interaction behavior and a custom appearance to all buttons within a view hierarchy.
public struct BaseButtonStyle: Hashable, Sendable {
    package enum Kind {
        case bordered
        case plain
        case borderless
    }

    package var kind: Kind

    /// A button style that applies the standard border style based on the button’s context.
    @available(iOS 15.0, tvOS 15.0, macCatalyst 15.0, *)
    public static let bordered = Self(kind: .bordered)
    /// A button style that doesn’t style or decorate its content while idle,
    /// but may apply a visual effect to indicate the pressed, focused, or enabled state of the button.
    public static let plain = Self(kind: .plain)
    /// A button style that doesn’t apply a border.
    ///
    /// On desktop operating systems it behaves mostly the same as ``ButtonStyle/plain``
    /// due to the SwiftUI borderless behavior on mac being stupid.
    /// The only difference is a default foreground color of gray being applied.
    public static let borderless = Self(kind: .borderless)
}

@MainActor
public protocol _InternalButtonStyle {
    var baseButtonStyle: BaseButtonStyle { get }
}

extension _InternalButtonStyle {
    public var baseButtonStyle: BaseButtonStyle { .plain }
}

@MainActor
public protocol ButtonStyle: _InternalButtonStyle {
    associatedtype Body: View
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> Self.Body
}

extension ButtonStyle {
    public typealias Configuration = ButtonStyleConfiguration
}

extension ButtonStyle where Self == PlainButtonStyle {
    public static var plain: PlainButtonStyle { PlainButtonStyle() }
}

extension ButtonStyle where Self == BorderedButtonStyle {
    public static var bordered: BorderedButtonStyle { BorderedButtonStyle() }
}

extension ButtonStyle where Self == BorderlessButtonStyle {
    public static var borderless: BorderlessButtonStyle { BorderlessButtonStyle() }
}

public struct ButtonStyleConfiguration {
    public let isPressed: Bool
    public let label: Label
    // TODO: Add button role support (ie .destructive, .cancel,...)
    // public let role: ButtonRole
    
    public struct Label: View {
        init<V: View>(body: V) {
            self.body = AnyView(body)
        }
        public let body: AnyView
    }
}

public struct BorderedButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            // change environment where necessary
            configuration.label
        } else {
            configuration.label
        }
    }
}

public struct BorderlessButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            // change environment where necessary
            configuration.label
        } else {
            configuration.label
        }
    }
}

public struct PlainButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.background(configuration.isPressed ? Color.red: Color.blue)
    }
}

extension BorderedButtonStyle: _InternalButtonStyle {
    public var baseButtonStyle: BaseButtonStyle { .bordered }
}
