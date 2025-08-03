#!/bin/bash

# --- Restore last used wallpaper for this theme ---
THEME_NAME="catppuccin_dark" # <-- CHANGE THIS FOR EACH SCRIPT
WALLPAPER_STATE_FILE="$HOME/.config/hypr/themes/${THEME_NAME}.wallpaper"

if [ -f "$WALLPAPER_STATE_FILE" ]; then
    # Read the wallpaper path from the state file
    WALLPAPER_PATH=$(cat "$WALLPAPER_STATE_FILE")
    
    # Check if the file actually exists
    if [ -f "$WALLPAPER_PATH" ]; then
        # Get the current monitor name
        MONITOR=$(hyprctl monitors | awk '/Monitor/ {print $2; exit}')

        # 1. Set the live wallpaper with correct quoting
        hyprctl hyprpaper preload "$WALLPAPER_PATH"
        hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER_PATH"

        # 2. Update hyprpaper.conf for persistence
        echo "preload = $WALLPAPER_PATH" > ~/.config/hypr/hyprpaper.conf
        echo "wallpaper = $MONITOR,$WALLPAPER_PATH" >> ~/.config/hypr/hyprpaper.conf
    fi
fi


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
hyprctl keyword general:col.active_border "rgba(89b4faee) rgba(cba6f7ee) 45deg"
hyprctl keyword general:col.inactive_border "rgba(585b70aa)"
hyprctl reload

# --- Waybar & Wofi CSS ---
# Ensure you have created these CSS files in your themes folder
ln -sf "$HOME/.config/hypr/themes/waybar_catppuccin.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/hypr/themes/wofi_catppuccin.css" "$HOME/.config/wofi/style.css"

# Reload Waybar to apply changes
killall -SIGUSR2 waybar

echo 'vim.cmd.colorscheme "catppuccin"' > ~/.config/nvim/lua/custom/theme.lua

notify-send "Theme Changed" "Set to Catppuccin Mocha."
