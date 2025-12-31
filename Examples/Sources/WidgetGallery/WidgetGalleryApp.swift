//
//  WidgetGalleryApp.swift
//  Examples
//
//  Created by Mia Koring on 31.12.25.
//

import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct WidgetGalleryApp: App {

    var body: some Scene {
        WindowGroup("Widget Gallery") {
            #hotReloadable {
                ContentView()
            }
        }
        .defaultSize(width: 400, height: 200)
    }
}

struct ContentView: View {
    @State var data = ContentViewModel()
    @FocusState var focus: Widget?

    var body: some View {
        Text("Focused widget: \(focus?.rawValue ?? "nil")")
            .frame(width: 200)
        ScrollView {
            TextField(text: $data.textField)
                .focusable()
                .focused($focus, equals: .textField)
            Slider($data.slider, minimum: -10, maximum: 10)
                .focused($focus, equals: .slider)
            /*ForEach(Widget.allCases) { widget in
                widget.view(with: $data)
                    .focusable()
                    .focused($focus, equals: widget)
            }*/
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var textField = "TextField"
    @Published var textEditor = "TextEditor"
    @Published var slider: Double = 0.0
    @Published var toggleSwitch = false
    @Published var checkbox = false
    @Published var toggleButton = false
}

@MainActor
enum Widget: String, CaseIterable {
    case text
    case textField
    case textEditor
    case slider
    case toggleSwitch
    case checkbox
    case toggleButton
}

extension Widget {
    @ViewBuilder
    func view(
        with data: Binding<ContentViewModel>
    ) -> some View {
        switch self {
            case .text:
                Text("Text")
            case .textField:
                TextField(text: data.textField)
            case .textEditor:
                TextEditor(text: data.textEditor)
                    .padding(3)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                    .frame(maxHeight: 100)
            case .slider:
                Slider(data.slider, minimum: -10, maximum: 10)
            case .toggleSwitch:
                Toggle("", active: data.toggleSwitch)
                    .toggleStyle(.switch)
            case .checkbox:
                Toggle("", active: data.checkbox)
                    .toggleStyle(.checkbox)
            case .toggleButton:
                Toggle("", active: data.toggleButton)
                    .toggleStyle(.button)
        }
    }
}
