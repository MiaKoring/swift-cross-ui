import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct GreetingGeneratorApp: App {
    @State var name = ""
    @State var greetings: [String] = []
    @State var isGreetingSelectable = false

    @State var isTextFocusable = true

    @FocusState var focus: Int?

    var body: some Scene {
        WindowGroup("Greeting Generator") {
            #hotReloadable {
                VStack {
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                        .sheet(
                            isPresented: .init(get: { return false }, set: { _ in }),
                            content: { Text("") }
                        )
                        .focused($focus, equals: 1)

                    HStack {
                        Button("Generate") {
                            greetings.append("Hello, \(name)!")
                        }
                        .focused($focus, equals: 2)
                        Button("Reset") {
                            greetings = []
                            name = ""
                        }
                        .focused($focus, equals: 3)
                    }
                    .focusable(isTextFocusable ? .disabled : .unmodified)

                    Text("\(focus ?? -1)")
                        .focusable(isTextFocusable)

                    Toggle("FocusableText", active: $isTextFocusable)
                        .toggleStyle(.switch)

                    Toggle("Selectable Greeting", isOn: $isGreetingSelectable)
                    if let latest = greetings.last {
                        LatestGreetingDisplay()
                            .environment(\.latestGreeting, latest)
                            .padding(.top, 5)
                            .textSelectionEnabled(isGreetingSelectable)

                        if greetings.count > 1 {
                            Text("History:")
                                .padding(.top, 20)

                            ScrollView {
                                ForEach(greetings.reversed()[1...], id: \.self) { greeting in
                                    Text(greeting)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(10)
            }
        }
    }
}

/// This intermediate view exists to show the usage of custom environment keys. In reality it is not necessary.
struct LatestGreetingDisplay: View {
    @Environment(\.latestGreeting) var value: String?

    var body: some View {
        Text(value ?? "nil")
    }
}

struct LatestGreetingKey: EnvironmentKey {
    typealias Value = String?
    static let defaultValue: Value = nil
}

extension EnvironmentValues {
    var latestGreeting: String? {
        get { self[LatestGreetingKey.self] }
        set { self[LatestGreetingKey.self] = newValue }
    }
}
