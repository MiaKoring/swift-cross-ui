import SwiftCrossUI
import Gtk
// MARK: - FocusState

class FocusStateManager {
    private var focusData = [ObjectIdentifier: Set<FocusData>]()
    private var lastFocused: ObjectIdentifier? = nil
    var shouldSkip: Bool = false
    
    func register(_ data: [FocusData], for widget: Gtk.Widget) {
        focusData[ObjectIdentifier(widget)] = Set(data)
        
        if data.contains(where: { $0.matches }),
           !widget.isVisible,
           widget.isFocusable
        {
            _ = widget.makeKey()
        }
    }
    
    func handleFocusChange(of identifier: ObjectIdentifier, toState isFocused: Bool) {
        guard let data = focusData[identifier] else {
            print("no data for \(identifier)")
            return
        }
        if isFocused {
            data.forEach { binding in
                binding.set()
            }
        } else {
            
            data.forEach { binding in
                binding.reset()
            }
        }
    }
}

extension GtkBackend {
    public func registerFocusObservers(
        _ data: [FocusData],
        on widget:  Gtk.Widget
    ) {
        // Some widget's focus is managed by descendants
        // Therefore widget.isFocusable would be false on them
        if widget is Gtk.Entry {
            guard !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) else {
                print("\(widget) already has EventControllerFocus")
                return
            }
            print("added focus controller to \(widget)")
            let focusController = EventControllerFocus()
            focusController.enter = { _ in
                print("Entry focus entered")
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: true
                )
            }
            focusController.leave = { _ in
                print("Entry focus left")
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: false
                )
            }
            widget.addEventController(focusController)
            focusManager.register(data, for: widget)
            return
        }
        guard
            widget.isFocusable
        else { return }
        
        focusManager.register(data, for: widget)
        if !widget.eventControllers.contains(where: { $0 is EventControllerFocus }) {
            let focusController = EventControllerFocus()
            focusController.notifyIsFocus = { _, _ in
                print("Focus of \(widget) changed to \(focusController.isFocus)")
                self.focusManager.handleFocusChange(
                    of: ObjectIdentifier(widget),
                    toState: focusController.isFocus
                )
            }
            widget.addEventController(focusController)
        }
    }
    
    public func createFocusContainer() -> Gtk.Widget {
        return Fixed()
    }
    
    public func updateFocusContainer(
        _ widget: Gtk.Widget,
        focusability: Focusability
    ) -> ObjectIdentifier? {
        /*let container = widget as! FocusabilityContainer
        if container.setFocusability(focusability),
           let window = container.window
        {
            return ObjectIdentifier(window)
        }*/
        return nil
    }
    
    public func setFocusEffectDisabled(on widget:  Gtk.Widget, disabled: Bool) {
        //widget.focusRingType = disabled ? .none : .default
    }
}
