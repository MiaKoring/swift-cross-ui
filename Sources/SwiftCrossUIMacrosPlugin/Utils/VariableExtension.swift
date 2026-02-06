import MacroToolkit
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

extension Variable {
    func hasMacroApplication(_ name: String) -> Bool {
        for attribute in _syntax.attributes {
            switch attribute {
                case .attribute(let attr):
                    if attr.attributeName.tokens(viewMode: .all).map({ $0.tokenKind }) == [.identifier(name)] {
                        return true
                    }
                default:
                    break
            }
        }
        return false
    }
}
