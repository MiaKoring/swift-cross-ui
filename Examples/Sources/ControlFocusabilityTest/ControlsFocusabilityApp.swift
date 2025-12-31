//
//  ControlsFocusabilityApp.swift
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

    var body: some Scene {
        WindowGroup("ControlsApp") {
            #hotReloadable {
                ScrollView {
                    VStack(spacing: 30) {
                        HStack {
                            VStack {
                                Text("Button")
                                Button("Click me!") {
                                    count += 1
                                }
                                .focusable(isButtonFocusable)
                                Text("Count: \(count)")
                            }
                            Toggle("focusable", active: $isButtonFocusable)
                                .focusable(false)
                        }
                        .padding(.bottom, 20)

                        #if !canImport(UIKitBackend)
                            HStack {
                                VStack {
                                    Text("Toggle button")
                                    Toggle("Toggle me!", active: $exampleButtonState)
                                        .toggleStyle(.button)
                                        .focusable(isToggleButtonFocusable)
                                    Text("Currently enabled: \(exampleButtonState)")
                                }
                                Toggle("focusable", active: $isToggleButtonFocusable)
                                    .focusable(false)
                            }
                            .padding(.bottom, 20)
                        #endif

                        HStack {
                            VStack {
                                Text("Toggle switch")
                                Toggle("Toggle me:", active: $exampleSwitchState)
                                    .toggleStyle(.switch)
                                    .focusable(isToggleSwitchFocusable)
                                Text("Currently enabled: \(exampleSwitchState)")
                            }
                            Toggle("focusable", active: $isToggleSwitchFocusable)
                                .focusable(false)
                        }

                        #if !canImport(UIKitBackend)
                            HStack {
                                VStack {
                                    Text("Checkbox")
                                    Toggle("Toggle me:", active: $exampleCheckboxState)
                                        .toggleStyle(.checkbox)
                                        .focusable(isCheckboxFocusable)
                                    Text("Currently enabled: \(exampleCheckboxState)")
                                }
                                Toggle("focusable", active: $isCheckboxFocusable)
                                    .focusable(false)
                            }
                        #endif
                        #if !os(tvOS)
                            HStack {
                                VStack {
                                    Text("Slider")
                                    Slider($sliderValue, minimum: 0, maximum: 10)
                                        .frame(maxWidth: 200)
                                        .focusable(isSliderFocusable)
                                    Text("Value: \(String(format: "%.02f", sliderValue))")
                                }
                                Toggle("focusable", active: $isSliderFocusable)
                                    .focusable(false)
                            }
                        #endif
                        HStack {
                            VStack {
                                Text("Text field")
                                TextField("Text field", text: $text)
                                    .focusable(isTextFieldFocusable)
                                Text("Value: \(text)")
                            }
                            Toggle("focusable", active: $isTextFieldFocusable)
                                .focusable(false)
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
                                    .focusable(isPickerFocusable)
                                }
                                Text("You chose: \(flavor ?? "Nothing yet!")")
                            }
                            Toggle("focusable", active: $isPickerFocusable)
                                .focusable(false)
                        }
                    }
                    .padding()
                    .disabled(!enabled)

                    Toggle(enabled ? "Disable all" : "Enable all", active: $enabled)
                        .padding()
                        .focusable(false)
                }
                .frame(minHeight: 600)
            }

        }.defaultSize(width: 400, height: 600)
    }
}
