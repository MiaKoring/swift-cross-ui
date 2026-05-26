#include "gtk_custom_button.h"

struct _GtkCustomButton {
    GtkFixed parent_instance;
};

G_DEFINE_TYPE(GtkCustomButton, gtk_custom_button, GTK_TYPE_FIXED)

static void gtk_custom_button_init(GtkCustomButton *self) {}
    
static void gtk_custom_button_class_init(GtkCustomButtonClass *klass) {
    GtkWidgetClass *widget_class = GTK_WIDGET_CLASS(klass);
    gtk_widget_class_set_accessible_role(widget_class, GTK_ACCESSIBLE_ROLE_BUTTON);
}

GtkWidget* gtk_custom_button_new(void) {
    return g_object_new(GTK_CUSTOM_BUTTON_TYPE, NULL);
}
