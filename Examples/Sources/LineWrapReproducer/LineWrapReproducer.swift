import DefaultBackend
import SwiftCrossUI

@main
struct LineWrapReproducer: App {
    var body: some Scene {
        WindowGroup("LineWrapReproducer") {
            ContentView()
        }
    }
}

struct ContentView: View {
    let loremIpsum =
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    
    var body: some View {
        // Line wraps don't happen
        // Outside of ScrollView, they do
        ScrollView {
            VStack {
                Text(loremIpsum)
                    .frame(maxWidth: 50)
                Divider()
                Text(loremIpsum)
                    .frame(maxWidth: 100)
                Divider()
                Text(loremIpsum)
                    .frame(maxWidth: 200)
                Divider()
                Text(loremIpsum)
            }
        }
    }
    
}
