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
            let extensionDecl = context.lexicalContext.first?.as(ExtensionDeclSyntax.self),
            let enclosingValueType = EnclosingType(
                rawValue: extensionDecl.extendedType.trimmedDescription)
        else {
            throw MacroError(
                "@Entry-annotated properties must be direct children of an EnvironmentValues or AppStorageValues extension."
            )
        }

        guard
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier,
            variable._syntax.bindingSpecifier.text == "var"
        else {
            throw MacroError("@Entry is only supported on single binding `var` declarations.")
        }

        if patternBinding.initialValue == nil,
            patternBinding.type?.isOptional != true
        {
            throw MacroError("@Entry requires an initial value for non-optional properties.")
        }

        let getterContent: String
        let setterContent: String

        switch enclosingValueType {
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
            let extensionDecl = context.lexicalContext.first?.as(ExtensionDeclSyntax.self),
            let enclosingValueType = EnclosingType(
                rawValue: extensionDecl.extendedType.trimmedDescription)
        else { return [] }  // No throw here, as it already throws at the accessor macro

        // Information about variable
        guard
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier,
            variable._syntax.bindingSpecifier.text == "var"
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
        switch enclosingValueType {
            case .environment:
                nameDeclaration = ""
            case .appStorage:
                nameDeclaration = "\nstatic let name = \"\(identifier)\""
        }

        return [
            DeclSyntax(
                stringLiteral: """
                    private struct __Key_\(identifier): \(enclosingValueType.keyName) {
                        \(defaultValueDeclaration)\(nameDeclaration)
                    } 
                    """)
        ]
    }

    enum EnclosingType: String {
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

        var keyName: String {
            "SwiftCrossUI.\(self.rawValue)Key"
        }
    }
}
