import CGtk
import GtkCHelpers

open class CustomButton: Widget {
    public var children: [Widget] = []
    
    public func put(_ child: Widget, x: Double, y: Double) {
        gtk_fixed_put(castedPointer(), child.widgetPointer, x, y)
        children.append(child)
        child.parentWidget = self
    }
    
    public func put(_ child: Widget, index: Int, x: Double, y: Double) {
        gtk_fixed_put(castedPointer(), child.widgetPointer, x, y)
        children.insert(child, at: index)
        child.parentWidget = self
    }
}
