#!/bin/bash

# --- Theme Variables ---
GTK_THEME="Catppuccin-Latte-Blue-Light"
ICON_THEME="Papyrus-Light" # Use a light icon variant
KVANTUM_THEME="Catppuccin-Latte-Blue"
KVANTUM_CONFIG_PATH="$HOME/.config/Kvantum/kvantum.kvconfig"
QT5CT_CONFIG_PATH="$HOME/.config/qt5ct/qt5ct.conf"

# --- Set GTK Theme ---
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Nerd Font 10"

# --- Set Qt Theme ---
# Set Kvantum theme by directly editing the config file (this is silent)
if [ -f "$KVANTUM_CONFIG_PATH" ]; then
    sed -i "s/^theme=.*/theme=$KVANTUM_THEME/" "$KVANTUM_CONFIG_PATH"
fi
# Set icon theme for Qt apps
if [ -f "$QT5CT_CONFIG_PATH" ]; then
    sed -i "s/^icon_theme=.*/icon_theme=$ICON_THEME/" "$QT5CT_CONFIG_PATH"
    sed -i "s/^style=.*/style=kvantum/" "$QT5CT_CONFIG_PATH"
fi

# --- Hyprland Border Colors ---
hyprctl keyword general:col.active_border "rgba(1e66f5ee) rgba(ea76cbee) 45deg"
hyprctl keyword general:col.inactive_border "rgba(bcc0caaa)"

# --- Waybar & Wofi CSS ---
# Ensure you have created these CSS files in your themes folder
ln -sf "$HOME/.config/hypr/themes/waybar_catppuccin.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/hypr/themes/wofi_catppuccin.css" "$HOME/.config/wofi/style.css"

# Reload Waybar to apply changes
killall -SIGUSR2 waybar

notify-send "Theme Changed" "Set to Catppuccin Mocha."
