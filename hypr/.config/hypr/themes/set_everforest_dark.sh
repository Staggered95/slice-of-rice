#!/bin/bash
THEME_NAME="everforest_dark" # Different for each script
WALLPAPER_STATE_FILE="$HOME/.config/hypr/themes/${THEME_NAME}.wallpaper"
GTK_THEME="Everforest-Green-Dark"
ICON_THEME="Colloid-Green-Dark"
CURSOR_THEME="Bibata-Original-Ice"
FONT_NAME="DejaVu Sans Book 11"
VSCODIUM_THEME="Everforest Dark"
VIVID_THEME="snazzy"

### GTK SETTINGS ###
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface font-name "$FONT_NAME"

### HYPRLAND ###
hyprctl keyword general:col.active_border "rgba(a7c080ee) rgba(dbbc7fee) 45deg"
hyprctl keyword general:col.inactive_border "rgba(4a555baa)"
hyprctl setcursor "$CURSOR_THEME" 26

### WAYBAR && WOFI && HYPRLOCK ###
ln -sf "$HOME/.config/hypr/themes/waybar/waybar_everforest_dark.css" "$HOME/.config/waybar/style.css"
ln -sf "$HOME/.config/hypr/themes/wofi/wofi_everforest_dark.css" "$HOME/.config/wofi/style.css"
ln -sf "$HOME/.config/hypr/themes/wofi/clipboard_everforest_dark.css" "$HOME/.config/wofi/style_clipboard.css"
ln -sf "$HOME/.config/hypr/themes/wofi/powermenu_everforest_dark.css" "$HOME/.config/wofi/style_powermenu.css"
ln -sf "$HOME/.config/hypr/themes/hyprlock/everforest_dark.conf" "$HOME/.config/hypr/hyprlock.conf"

### KITTY, DUNST, P10K ###
ln -sf "$HOME/.config/hypr/themes/kitty/everforest_dark.conf" "$HOME/.config/kitty/themes/current.conf"
ln -sf "$HOME/.config/hypr/themes/dunst/everforest_dark" "$HOME/.config/dunst/dunstrc"
ln -sf "$HOME/.config/hypr/themes/p10k/everforest_dark" "$HOME/.p10k.zsh"

### VSCODIUM ###
SETTINGS="$HOME/.config/VSCodium/User/settings.json"
jq ".\"workbench.colorTheme\" = \"$VSCODIUM_THEME\"" "$SETTINGS" >"$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

### WALLPAPER ###
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
    echo "preload = $WALLPAPER_PATH" >~/.config/hypr/hyprpaper.conf
    echo "wallpaper = $MONITOR,$WALLPAPER_PATH" >>~/.config/hypr/hyprpaper.conf
  fi
fi

### ECHO && EXPORTS ###
echo "export LS_COLORS='$(vivid generate $VIVID_THEME)'" >~/.cache/ls_colors
echo 'vim.g.everforest_background = "hard" vim.cmd.colorscheme "everforest"' >~/.config/nvim/lua/custom/theme.lua
export LS_COLORS="$(vivid generate "$VIVID_THEME")"

### RELOADS ###
killall -SIGUSR2 waybar
killall dunst && dunst &
source ~/.cache/ls_colors

##### NOTIFY #####
notify-send "Theme Changed to " $THEME_NAME
