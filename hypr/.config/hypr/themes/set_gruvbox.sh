#!/bin/bash

# --- Theme Variables ---
GTK_THEME="Gruvbox-Material-Dark"
ICON_THEME="Papyrus-Dark" # Or another icon theme you like
KVANTUM_THEME="Gruvbox-Dark"
KVANTUM_CONFIG_PATH="$HOME/.config/Kvantum/kvantum.kvconfig"
QT5CT_CONFIG_PATH="$HOME/.config/qt5ct/qt5ct.conf"

# --- Set GTK Theme ---
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

# --- Set Qt Theme ---
if [ -f "$KVANTUM_CONFIG_PATH" ]; then
    sed -i "s/^theme=.*/theme=$KVANTUM_THEME/" "$KVANTUM_CONFIG_PATH"
fi
if [ -f "$QT5CT_CONFIG_PATH" ]; then
    sed -i "s/^icon_theme=.*/icon_theme=$ICON_THEME/" "$QT5CT_CONFIG_PATH"
fi

# --- Hyprland Border Colors ---
hyprctl keyword general:col.active_border "rgba(fabd2fee) rgba(fe8019ee) 45deg"
hyprctl keyword general:col.inactive_border "rgba(504945aa)"

# --- Waybar & Wofi CSS ---
# You would need to create waybar_gruvbox.css and wofi_gruvbox.css
# ln -sf "$HOME/.config/hypr/themes/waybar_gruvbox.css" "$HOME/.config/waybar/style.css"
# ln -sf "$HOME/.config/hypr/themes/wofi_gruvbox.css" "$HOME/.config/wofi/style.css"

killall -SIGUSR2 waybar

notify-send "Theme Changed" "Set to Gruvbox."
