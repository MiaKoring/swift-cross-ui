import CGtk

public extension Entry {
    func grabFocusWithoutSelecting() {
        g_idle_add({ (data) -> Int32 in
            gtk_widget_grab_focus(data?.assumingMemoryBound(to: GtkWidget.self))
            return 0
        }, widgetPointer)
        //gtk_entry_grab_focus_without_selecting(self.castedPointer())
    }
}
