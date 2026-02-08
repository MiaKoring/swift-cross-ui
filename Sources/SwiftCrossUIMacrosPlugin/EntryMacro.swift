import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct EntryMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard
            let extensionDecl = context.lexicalContext.compactMap({ syntax in
                syntax.as(ExtensionDeclSyntax.self)
            }).first
        else { return [] }
        let extendedType = extensionDecl.extendedType.trimmedDescription

        guard let keyName = KeyName(rawValue: extendedType) else { return [] }

        guard
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier
        else { return [] }

        if patternBinding.initialValue == nil,
            patternBinding.type?.isOptional != true
        {
            throw MacroError("@Entry requires an initial value to be set.")
        }

        let getterContent: String
        let setterContent: String

        switch keyName {
            case .environment:
                getterContent = "self[__Key_\(identifier).self]"
                setterContent = "self[__Key_\(identifier).self] = newValue"
            case .appStorage:
                getterContent = "__getValue(__Key_\(identifier).self)"
                setterContent = "__setValue(__Key_\(identifier).self, newValue: newValue)"
        }

        return [
            AccessorDeclSyntax(
                stringLiteral: """
                    get {
                        \(getterContent)
                    }
                    """),
            AccessorDeclSyntax(
                stringLiteral: """
                    set {
                        \(setterContent)
                    }
                    """),
        ]
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        // Information about extension context
        guard
            let extensionDecl = context.lexicalContext.compactMap({ syntax in
                syntax.as(ExtensionDeclSyntax.self)
            }).first
        else { return [] }
        let extendedType = extensionDecl.extendedType.trimmedDescription

        guard let keyName = KeyName(rawValue: extendedType) else { return [] }

        // Information about variable
        guard
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier
        else { return [] }

        let typeDeclaration: String
        if let typeName = patternBinding.type?.normalizedDescription {
            typeDeclaration = ": \(typeName)"
        } else {
            typeDeclaration = ""
        }

        // Optional types get nil as default value if no initial value is provided
        var defaultValueDeclaration = ""
        if patternBinding.initialValue == nil,
            patternBinding.type?.isOptional == true
        {
            defaultValueDeclaration = "static let defaultValue\(typeDeclaration) = nil"
        } else if let initialValue = patternBinding.initialValue?._syntax.trimmedDescription {
            defaultValueDeclaration = "static let defaultValue\(typeDeclaration) = \(initialValue)"
        }  // No else case here, as it already throws at the accessor macro

        // AppStorage has got a special requirement to know the key name as string
        let nameDeclaration: String
        switch keyName {
            case .environment:
                nameDeclaration = ""
            case .appStorage:
                nameDeclaration = "\nstatic let name = \"\(identifier)\""
        }

        return [
            DeclSyntax(
                stringLiteral: """
                    private struct __Key_\(identifier): SwiftCrossUI.\(keyName.rawValue)Key {
                        \(defaultValueDeclaration)\(nameDeclaration)
                    } 
                    """)
        ]

        return []
    }

    enum KeyName: String {
        case environment = "Environment"
        case appStorage = "AppStorage"

        init?(rawValue: String) {
            switch rawValue {
                case "SwiftCrossUI.EnvironmentValues", "EnvironmentValues":
                    self = .environment
                case "SwiftCrossUI.AppStorageValues", "AppStorageValues":
                    self = .appStorage
                default:
                    return nil
            }
        }
    }
}
