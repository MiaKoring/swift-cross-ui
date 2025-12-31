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

                    Toggle("Selectable Greeting", active: $isGreetingSelectable)
                    if let latest = greetings.last {
                        Text(latest)
                            .padding(.top, 5)
                            .textSelectionEnabled(isGreetingSelectable)

                        if greetings.count > 1 {
                            Text("History:")
                                .padding(.top, 20)

                            ScrollView {
                                ForEach(greetings.reversed()[1...]) { greeting in
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
