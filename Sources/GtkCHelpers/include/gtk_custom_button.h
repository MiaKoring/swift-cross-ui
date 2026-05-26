#ifndef __CUSTOM_BUTTON_H_
#define __CUSTOM_BUTTON_H_

#include <gtk/gtk.h>
#include <glib-object.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#define GTK_TYPE_MY_BUTTON (gtk_custom_button_get_type())
G_DECLARE_FINAL_TYPE(GtkCustomButton, gtk_custom_button, GTK, CUSTOM_BUTTON, GtkFixed)

GtkWidget* gtk_custom_button_new(void);

#define GTK_CUSTOM_BUTTON_TYPE (gtk_custom_button_get_type())

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __CUSTOM_BUTTON_H_ */
