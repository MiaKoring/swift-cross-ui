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
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier
        else { return [] }
        
        if
            patternBinding.initialValue == nil,
            patternBinding.type?.isOptional != true
        {
            throw MacroError("@Entry requires an initial value to be set.")
        }
        
        return [
            AccessorDeclSyntax(stringLiteral: """
            get {
                self[__Key_\(identifier).self]
            }
            """),
            AccessorDeclSyntax(stringLiteral: """
            set {
                self[__Key_\(identifier).self] = newValue
            }
            """)
        ]
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let extensionDecl = context.lexicalContext.compactMap({ syntax in
            syntax.as(ExtensionDeclSyntax.self)
        }).first else { return [] }
        let extendedType = extensionDecl.extendedType.trimmedDescription
        
        guard let keyName = KeyName(rawValue: extendedType) else { return [] }
        
        guard
            let variable = Decl(declaration).asVariable,
            let patternBinding = destructureSingle(variable.bindings),
            let identifier = patternBinding.identifier
        else { return [] }
        
        let typeDeclaration: String
        if let typeName = patternBinding.type?.normalizedDescription {
            typeDeclaration = ": \(typeName)"
        } else { typeDeclaration = "" }
        
        if
            patternBinding.initialValue == nil,
            patternBinding.type?.isOptional == true
        {
            return [
                DeclSyntax(stringLiteral: """
                private struct __Key_\(identifier): SwiftCrossUI.\(keyName.rawValue)Key {
                    static let defaultValue\(typeDeclaration) = nil
                } 
                """)
            ]
        } else if
            let initialValue = patternBinding.initialValue?._syntax.trimmedDescription
        {
            return [
                DeclSyntax(stringLiteral: """
                private struct __Key_\(identifier): SwiftCrossUI.\(keyName.rawValue)Key {
                    static let defaultValue\(typeDeclaration) = \(initialValue)
                } 
                """)
            ]
        }
        
        return []
    }
    
    enum KeyName: String {
        case environment = "Environment"
        
        init?(rawValue: String) {
            switch rawValue {
                case "SwiftCrossUI.EnvironmentValues", "EnvironmentValues":
                    self = .environment
                default:
                    return nil
            }
        }
    }
}
