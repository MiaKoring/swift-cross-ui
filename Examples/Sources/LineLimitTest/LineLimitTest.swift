import DefaultBackend
import SwiftCrossUI

@main
struct XSwiftToolsApp: App {
    var body: some Scene {
        WindowGroup("XSwiftTools") {
            ContentView()
        }
    }
}

struct ContentView: View {
    let loremIpsum =
        "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

    var body: some View {
        VStack {
            Text(loremIpsum)
                .lineLimit(1)
            Divider()
            Text(loremIpsum)
                .lineLimit(2)
            Divider()
            Text(loremIpsum)
                .lineLimit(3)
            Divider()
            Text(loremIpsum)
        }
    }

}
