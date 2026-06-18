#!/bin/bash
# ~/.config/hypr/scripts/apply-ayaka.sh

THEME_KEY=$1
THEMES_FILE="$HOME/.config/hypr/ayaka.json"
WALLPAPER_STATE_FILE="$HOME/.config/hypr/themes/wallpaper/${THEME_KEY}.wallpaper"

# 1. Load basic colors from JSON (if you still want to manage hex codes there)
eval $(jq -r --arg THEME_KEY "$THEME_KEY" '
    (.[$THEME_KEY].metadata | to_entries[] | "\(.key)=\(.value|@sh)"),
    (.[$THEME_KEY].colors | to_entries[] | .key as $parent | .value | to_entries[] | "\($parent)_\(.key)=\(.value|@sh)")
' "$THEMES_FILE")

# 2. Handle Wallpaper (Simplified for static/gif based on your previous script)
if [ -f "$WALLPAPER_STATE_FILE" ]; then
  WALLPAPER_PATH=$(cat "$WALLPAPER_STATE_FILE")
else
  WALLPAPER_PATH="$HOME/$default_wallpaper"
fi

if [ -f "$WALLPAPER_PATH" ]; then
  killall mpvpaper &>/dev/null
  if ! pgrep -x awww-daemon >/dev/null; then
    awww-daemon &>/dev/null &
    sleep 0.5
  fi
  awww img "$WALLPAPER_PATH" --transition-type grow
fi

sleep 1

# 3. Apply Core System Settings (GTK, Hyprland, etc.)
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
gsettings set org.gnome.desktop.interface font-name "$font_name"

hyprctl keyword general:col.active_border "$hyprland_active_border"
hyprctl keyword general:col.inactive_border "$hyprland_inactive_border"
hyprctl setcursor "$cursor_theme" "$cursor_size"

# 4. WAYBAR: Kill and launch with explicit configs
killall waybar
waybar -c "$HOME/.config/hypr/themes/ayaka/waybar/config.jsonc" -s "$HOME/.config/hypr/themes/ayaka/waybar/style.css" &>/dev/null &

# 5. DUNST: Point to a static Ayaka dunstrc
# --- DUNST: Point Dunst to the isolated config ---
cp "$HOME/.config/hypr/themes/ayaka/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
killall dunst
dunst &>/dev/null &

# 6. KITTY / TERMINAL: Point kitty to an isolated config
cp "$HOME/.config/hypr/themes/ayaka/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
/usr/bin/kill -SIGUSR1 $(pidof kitty)

# --- WOFI: Point Wofi to isolated configs ---

WOFI_AYAKA_DIR="$HOME/.config/hypr/themes/ayaka/wofi"
WOFI_MAIN_DIR="$HOME/.config/wofi"

cp "$WOFI_AYAKA_DIR/style.css" "$WOFI_MAIN_DIR/style.css"
cp "$WOFI_AYAKA_DIR/style_clipboard.css" "$WOFI_MAIN_DIR/style_clipboard.css"
cp "$WOFI_AYAKA_DIR/style_powermenu.css" "$WOFI_MAIN_DIR/style_powermenu.css"

# Notify
UPTIME=$(cut -d'.' -f1 /proc/uptime)
if [ "$UPTIME" -gt 30 ]; then
  notify-send "Kamisato Art" "Ayaka theme loaded." -i "$HOME/.config/hypr/themes/ayaka/icon.png"
fi
