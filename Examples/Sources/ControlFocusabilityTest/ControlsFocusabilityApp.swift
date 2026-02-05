import DefaultBackend
import SwiftCrossUI

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif

@main
@HotReloadable
struct ControlsFocusabilityApp: App {
    @State var count = 0
    @State var exampleButtonState = false
    @State var exampleSwitchState = false
    @State var exampleCheckboxState = false
    @State var sliderValue = 5.0
    @State var text = ""
    @State var flavor: String? = nil
    @State var enabled = true
    @State var isButtonFocusable = true
    @State var isToggleButtonFocusable = true
    @State var isToggleSwitchFocusable = true
    @State var isCheckboxFocusable = true
    @State var isSliderFocusable = true
    @State var isTextFieldFocusable = true
    @State var isPickerFocusable = true

    @FocusState var focused: Int?

    var body: some Scene {
        WindowGroup("ControlsApp") {
            #hotReloadable {
                ScrollView {
                    VStack(spacing: 30) {
                        Button("randomize focus") {
                            focused = Int.random(in: 1...7)
                        }
                        .padding(.bottom, 20)

                        HStack {
                            VStack {
                                Text("Button")
                                Button("Click me!") {
                                    count += 1
                                }
                                .focusable(isButtonFocusable ? .unmodified : .disabled)
                                .focused($focused, equals: 1)
                                .focusEffectDisabled()
                                Text("Count: \(count)")
                            }
                            Toggle("focusable", isOn: $isButtonFocusable)
                                .focusable(.disabled)
                        }
                        .padding(.bottom, 20)

                        #if !canImport(UIKitBackend)
                            HStack {
                                VStack {
                                    Text("Toggle button")
                                    Toggle("Toggle me!", isOn: $exampleButtonState)
                                        .toggleStyle(.button)
                                        .focusable(
                                            isToggleButtonFocusable ? .unmodified : .disabled
                                        )
                                        .focused($focused, equals: 2)
                                    Text("Currently enabled: \(exampleButtonState)")
                                }
                                Toggle("focusable", isOn: $isToggleButtonFocusable)
                                    .focusable(.disabled)
                            }
                            .padding(.bottom, 20)
                        #endif

                        HStack {
                            VStack {
                                Text("Toggle switch")
                                Toggle("Toggle me:", isOn: $exampleSwitchState)
                                    .toggleStyle(.switch)
                                    .focusable(isToggleSwitchFocusable ? .unmodified : .disabled)
                                    .focused($focused, equals: 3)
                                Text("Currently enabled: \(exampleSwitchState)")
                            }
                            Toggle("focusable", isOn: $isToggleSwitchFocusable)
                                .focusable(.disabled)
                        }

                        #if !canImport(UIKitBackend)
                            HStack {
                                VStack {
                                    Text("Checkbox")
                                    Toggle("Toggle me:", isOn: $exampleCheckboxState)
                                        .toggleStyle(.checkbox)
                                        .focusable(isCheckboxFocusable ? .unmodified : .disabled)
                                        .focused($focused, equals: 4)
                                    Text("Currently enabled: \(exampleCheckboxState)")
                                }
                                Toggle("focusable", isOn: $isCheckboxFocusable)
                                    .focusable(.disabled)
                            }
                        #endif
                        #if !os(tvOS)
                            HStack {
                                VStack {
                                    Text("Slider")
                                    Slider(value: $sliderValue, in: 0...10)
                                        .frame(maxWidth: 200)
                                        .focusable(isSliderFocusable ? .unmodified : .disabled)
                                        .focused($focused, equals: 5)
                                    Text("Value: \(String(format: "%.02f", sliderValue))")
                                }
                                Toggle("focusable", isOn: $isSliderFocusable)
                                    .focusable(.disabled)
                            }
                        #endif
                        HStack {
                            VStack {
                                Text("Text field")
                                TextField("Text field", text: $text)
                                    .focusable(isTextFieldFocusable ? .unmodified : .disabled)
                                    .focused($focused, equals: 6)
                                Text("Value: \(text)")
                            }
                            Toggle("focusable", isOn: $isTextFieldFocusable)
                                .focusable(.disabled)
                        }

                        HStack {
                            VStack {
                                Text("Drop down")
                                HStack {
                                    Text("Flavor: ")
                                    Picker(
                                        of: ["Vanilla", "Chocolate", "Strawberry"],
                                        selection: $flavor
                                    )
                                    .focusable(isPickerFocusable ? .unmodified : .disabled)
                                    .focused($focused, equals: 7)
                                }
                                Text("You chose: \(flavor ?? "Nothing yet!")")
                            }
                            Toggle("focusable", isOn: $isPickerFocusable)
                                .focusable(.disabled)
                        }
                    }
                    .padding()
                    .disabled(!enabled)

                    Toggle(enabled ? "Disable all" : "Enable all", isOn: $enabled)
                        .padding()
                        .focusable(.disabled)
                }
                .environment(\.colorScheme, .dark)
                .frame(minHeight: 600)
            }

        }.defaultSize(width: 400, height: 600)
    }
}
