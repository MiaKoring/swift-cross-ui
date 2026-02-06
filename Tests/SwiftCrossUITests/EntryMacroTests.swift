import Testing
import SwiftSyntaxMacrosGenericTestSupport
import SwiftSyntaxMacros
import SwiftCrossUIMacrosPlugin
import SwiftSyntaxMacroExpansion

fileprivate let testMacros: [String: MacroSpec] = [
    "Entry": MacroSpec(type: EntryMacro.self)
]

@Suite("Testing @Entry Macro")
struct EntryMacroTests {
    @Test("Entry generates without type annotation")
    func testEntryGeneratesWithLiteral() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var test = 22
            }
            """,
            expandedSource: """
            extension EnvironmentValues {
                var test {
                    get {
                        self[__Key_test.self]
                    }
                    set {
                        self[__Key_test.self] = newValue
                    }
                }
            
                private struct __Key_test: SwiftCrossUI.EnvironmentKey {
                    static let defaultValue = 22
                }
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Entry generates with type annotation")
    func testGeneratesWithTypeAnnotation() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var test: UInt64 = 22
            }
            """,
            expandedSource: """
            extension EnvironmentValues {
                var test: UInt64 {
                    get {
                        self[__Key_test.self]
                    }
                    set {
                        self[__Key_test.self] = newValue
                    }
                }

                private struct __Key_test: SwiftCrossUI.EnvironmentKey {
                    static let defaultValue: UInt64 = 22
                }
            }
            """,
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Entry throws without initial value")
    func entryThrowsWithoutInitialValue() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var test: UInt64
            }
            """,
            expandedSource: """
            extension EnvironmentValues {
                var test: UInt64
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "MacroError(message: \"@Entry requires an initial value to be set.\")",
                    line: 2,
                    column: 5
                )
            ],
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
    
    @Test("Entry generates default value nil without initial value on Optional type definition")
    func entryGeneratesDefaultValueNilWithoutInitialValueOnOptionalTypeDefinition() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @Entry var test: UInt64?
                @Entry var test1: Optional<UInt64>
            }
            """,
            expandedSource: """
            extension EnvironmentValues {
                var test: UInt64? {
                    get {
                        self[__Key_test.self]
                    }
                    set {
                        self[__Key_test.self] = newValue
                    }
                }
            
                private struct __Key_test: SwiftCrossUI.EnvironmentKey {
                    static let defaultValue: UInt64? = nil
                }
                var test1: Optional<UInt64> {
                    get {
                        self[__Key_test1.self]
                    }
                    set {
                        self[__Key_test1.self] = newValue
                    }
                }

                private struct __Key_test1: SwiftCrossUI.EnvironmentKey {
                    static let defaultValue: Optional<UInt64> = nil
                }
            }
            """,
            diagnostics: [],
            macroSpecs: testMacros,
            failureHandler: { spec in
                Issue.record(spec.issueComment)
            }
        )
    }
}

