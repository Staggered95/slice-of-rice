#!/bin/bash

THEME_KEY=$1
THEMES_FILE="$HOME/.config/hypr/themes.json"
WALLPAPER_STATE_FILE="$HOME/.config/hypr/themes/wallpaper/${THEME_KEY}.wallpaper"
LOCKPAPER_STATE_FILE="$HOME/.config/hypr/themes/lockpaper/${THEME_KEY}.lockpaper"

# --- Read all variables from the nested JSON in one command ---
# This creates variables like: gtk_theme, icon_theme, hyprland_active_border, waybar_bar_bg, etc.
eval $(jq -r --arg THEME_KEY "$THEME_KEY" '
    (.[$THEME_KEY].metadata | to_entries[] | "\(.key)=\(.value|@sh)"),
    (.[$THEME_KEY].colors | to_entries[] | .key as $parent | .value | to_entries[] | "\($parent)_\(.key)=\(.value|@sh)")
' "$THEMES_FILE")

# Determine which wallpaper to use: the user's last choice, or the theme's default.
if [ -f "$WALLPAPER_STATE_FILE" ]; then
  # Use the user's saved wallpaper if it exists
  WALLPAPER_PATH=$(cat "$WALLPAPER_STATE_FILE")
else
  # Otherwise, use the theme's default wallpaper
  WALLPAPER_PATH="$HOME/$default_wallpaper"
fi

### WALLPAPER ###
if [ -f "$WALLPAPER_PATH" ]; then
  # Check the file extension
  FILE_EXTENSION="${WALLPAPER_PATH##*.}"
  MONITOR=$(hyprctl monitors | awk '/Monitor/ {print $2; exit}')

  if [[ "mp4|mov|mkv" =~ $FILE_EXTENSION ]]; then
    # --- Restore a VIDEO wallpaper ---
    swww kill
    mpvpaper -p -o "--loop-file=inf --no-audio" "$MONITOR" "$WALLPAPER_PATH"
  else
    # --- Restore a STATIC or GIF wallpaper ---
    killall mpvpaper &>/dev/null
    if ! pgrep -x swww-daemon >/dev/null; then
      swww-daemon &>/dev/null &
      sleep 0.5
    fi
    swww img "$WALLPAPER_PATH" --transition-type grow
  fi
fi

sleep 1

# --- Apply Settings ---
# GTK
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
gsettings set org.gnome.desktop.interface font-name "$font_name"

# Hyprland
hyprctl keyword general:col.active_border "$hyprland_active_border"
hyprctl keyword general:col.inactive_border "$hyprland_inactive_border"
hyprctl setcursor "$cursor_theme" "$cursor_size"

SETTINGS="$HOME/.config/VSCodium/User/settings.json"
jq ".\"workbench.colorTheme\" = \"$vs_codium_theme\"" "$SETTINGS" >"$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

echo "export LS_COLORS='$(vivid generate $vivid_theme)'" >~/.cache/ls_colors
export LS_COLORS="$(vivid generate "$vivid_theme")"

# --- Neovim ---
NVIM_THEME_FILE="$HOME/.config/nvim/lua/custom/theme.lua"
# Create the Lua command string
LUA_CMD="vim.cmd.colorscheme '$nvim_theme'"
# If a specific background is set in the JSON, add it to the command
if [ -n "$nvim_background" ]; then
  LUA_CMD="vim.g.everforest_background = '$nvim_background' $LUA_CMD"
fi
# Write the final command to the theme file
echo "$LUA_CMD" >"$NVIM_THEME_FILE"

# --- Restore last used lock screen wallpaper ---
if [ -f "$LOCKPAPER_STATE_FILE" ]; then
  # Use the user's saved wallpaper if it exists
  LOCKPAPER_PATH=$(cat "$LOCKPAPER_STATE_FILE")
else
  # Otherwise, use the theme's default lockpaper
  LOCKPAPER_PATH="$HOME/$default_lockpaper"
fi

if [ -f "$LOCKPAPER_PATH" ]; then
  # Use sed to update the hyprlock config file
  sed -i "s|path = .* # LOCK_WALL|path = $LOCKPAPER_PATH # LOCK_WALL|g" ~/.config/hypr/hyprlock.conf
fi

# --- TEMPLATE PATCHING ---
# Waybar
WAYBAR_TEMPLATE="$HOME/.config/waybar/style.css.template"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
sed -e "s|__bar_bg__|$waybar_bar_bg|g" \
  -e "s|__main_bg__|$waybar_main_bg|g" \
  -e "s|__main_fg__|$waybar_main_fg|g" \
  -e "s|__active_bg__|$waybar_active_bg|g" \
  -e "s|__active_fg__|$waybar_active_fg|g" \
  -e "s|__hover_bg__|$waybar_hover_bg|g" \
  -e "s|__hover_fg__|$waybar_hover_fg|g" \
  -e "s|__focus_bg__|$waybar_focus_bg|g" \
  -e "s|__focus_fg__|$waybar_focus_fg|g" \
  -e "s|__battery_charging_bg__|$waybar_battery_charging_bg|g" \
  -e "s|__battery_warning_bg__|$waybar_battery_warning_bg|g" \
  -e "s|__battery_critical_bg__|$waybar_battery_critical_bg|g" \
  -e "s|__battery_charging_fg__|$waybar_battery_charging_fg|g" \
  -e "s|__battery_warning_fg__|$waybar_battery_warning_fg|g" \
  -e "s|__battery_critical_fg__|$waybar_battery_critical_fg|g" \
  -e "s|__power_bg__|$waybar_power_bg|g" \
  -e "s|__power_fg__|$waybar_power_fg|g" \
  -e "s|__blink_bg__|$waybar_blink_bg|g" \
  -e "s|__blink_fg__|$waybar_blink_fg|g" \
  -e "s|__disabled_bg__|$waybar_disabled_bg|g" \
  -e "s|__disabled_fg__|$waybar_disabled_fg|g" \
  "$WAYBAR_TEMPLATE" >"$WAYBAR_STYLE"

# --- Kitty ---
KITTY_TEMPLATE="$HOME/.config/kitty/kitty.conf.template"
KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"

sed -e "s/__font_family__/$kitty_font_family/g" \
  -e "s/__font_size__/$kitty_font_size/g" \
  -e "s/__background_opacity__/$kitty_background_opacity/g" \
  -e "s/__window_padding_width__/$kitty_window_padding_width/g" \
  -e "s/__foreground__/$kitty_foreground/g" \
  -e "s/__background__/$kitty_background/g" \
  -e "s/__selection_foreground__/$kitty_selection_foreground/g" \
  -e "s/__selection_background__/$kitty_selection_background/g" \
  -e "s/__cursor__/$kitty_cursor/g" \
  -e "s/__url_color__/$kitty_url_color/g" \
  -e "s/__color0__/$kitty_color0/g" \
  -e "s/__color8__/$kitty_color8/g" \
  -e "s/__color1__/$kitty_color1/g" \
  -e "s/__color9__/$kitty_color9/g" \
  -e "s/__color2__/$kitty_color2/g" \
  -e "s/__color10__/$kitty_color10/g" \
  -e "s/__color3__/$kitty_color3/g" \
  -e "s/__color11__/$kitty_color11/g" \
  -e "s/__color4__/$kitty_color4/g" \
  -e "s/__color12__/$kitty_color12/g" \
  -e "s/__color5__/$kitty_color5/g" \
  -e "s/__color13__/$kitty_color13/g" \
  -e "s/__color6__/$kitty_color6/g" \
  -e "s/__color14__/$kitty_color14/g" \
  -e "s/__color7__/$kitty_color7/g" \
  -e "s/__color15__/$kitty_color15/g" \
  "$KITTY_TEMPLATE" >"$KITTY_CONFIG"

# --- Dunst ---
DUNST_TEMPLATE="$HOME/.config/dunst/dunstrc.template"
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"

# This command reads the template, replaces all placeholders with the
# dunst-specific variables loaded from your themes.json,
# and writes the final, themed dunstrc.
sed -e "s/__icon_theme__/$dunst_icon_theme/g" \
  -e "s/__urge_low_bg__/$dunst_urge_low_bg/g" \
  -e "s/__urge_low_fg__/$dunst_urge_low_fg/g" \
  -e "s/__urge_low_frame__/$dunst_urge_low_frame/g" \
  -e "s/__urge_norm_bg__/$dunst_urge_norm_bg/g" \
  -e "s/__urge_norm_fg__/$dunst_urge_norm_fg/g" \
  -e "s/__urge_norm_frame__/$dunst_urge_norm_frame/g" \
  -e "s/__urge_crit_bg__/$dunst_urge_crit_bg/g" \
  -e "s/__urge_crit_fg__/$dunst_urge_crit_fg/g" \
  -e "s/__urge_crit_frame__/$dunst_urge_crit_frame/g" \
  -e "s/__osd_progress_frame__/$dunst_osd_progress_frame/g" \
  -e "s/__osd_progress_bg__/$dunst_osd_progress_bg/g" \
  -e "s/__osd_progress_fg__/$dunst_osd_progress_fg/g" \
  "$DUNST_TEMPLATE" >"$DUNST_CONFIG"

# --- Wofi ---
WOFI_TEMPLATE="$HOME/.config/wofi/style.css.template"
WOFI_STYLE="$HOME/.config/wofi/style.css"

sed -e "s/__window_bg__/$wofi_window_bg/g" \
  -e "s/__window_border__/$wofi_window_border/g" \
  -e "s/__input_bg__/$wofi_input_bg/g" \
  -e "s/__input_fg__/$wofi_input_fg/g" \
  -e "s/__input_border__/$wofi_input_border/g" \
  -e "s/__input_focus_border__/$wofi_input_focus_border/g" \
  -e "s/__entry_main_bg__/$wofi_entry_main_bg/g" \
  -e "s/__entry_main_fg__/$wofi_entry_main_fg/g" \
  -e "s/__entry_selected_bg__/$wofi_entry_selected_bg/g" \
  -e "s/__entry_selected_fg__/$wofi_entry_selected_fg/g" \
  -e "s/__entry_hover_bg__/$wofi_entry_hover_bg/g" \
  "$WOFI_TEMPLATE" >"$WOFI_STYLE"

WOFI_CLIPBOARD_TEMPLATE="$HOME/.config/wofi/clipboard_style.css.template"
WOFI_CLIPBOARD_STYLE="$HOME/.config/wofi/style_clipboard.css"

sed -e "s/__window_bg__/$wofi_window_bg/g" \
  -e "s/__window_border__/$wofi_window_border/g" \
  -e "s/__input_bg__/$wofi_input_bg/g" \
  -e "s/__input_fg__/$wofi_input_fg/g" \
  -e "s/__input_border__/$wofi_input_border/g" \
  -e "s/__input_focus_border__/$wofi_input_focus_border/g" \
  -e "s/__entry_main_bg__/$wofi_entry_main_bg/g" \
  -e "s/__entry_main_fg__/$wofi_entry_main_fg/g" \
  -e "s/__entry_selected_bg__/$wofi_entry_selected_bg/g" \
  -e "s/__entry_selected_fg__/$wofi_entry_selected_fg/g" \
  -e "s/__entry_hover_bg__/$wofi_entry_hover_bg/g" \
  "$WOFI_CLIPBOARD_TEMPLATE" >"$WOFI_CLIPBOARD_STYLE"

WOFI_POWERMENU_TEMPLATE="$HOME/.config/wofi/powermenu_style.css.template"
WOFI_POWERMENU_STYLE="$HOME/.config/wofi/style_powermenu.css"

sed -e "s/__window_bg__/$wofi_window_bg/g" \
  -e "s/__window_border__/$wofi_window_border/g" \
  -e "s/__input_bg__/$wofi_input_bg/g" \
  -e "s/__input_fg__/$wofi_input_fg/g" \
  -e "s/__input_border__/$wofi_input_border/g" \
  -e "s/__input_focus_border__/$wofi_input_focus_border/g" \
  -e "s/__entry_main_bg__/$wofi_entry_main_bg/g" \
  -e "s/__entry_main_fg__/$wofi_entry_main_fg/g" \
  -e "s/__entry_selected_bg__/$wofi_entry_selected_bg/g" \
  -e "s/__entry_selected_fg__/$wofi_entry_selected_fg/g" \
  -e "s/__entry_hover_bg__/$wofi_entry_hover_bg/g" \
  "$WOFI_POWERMENU_TEMPLATE" >"$WOFI_POWERMENU_STYLE"

P10K_CONFIG="$HOME/.p10k.zsh"

if [ -f "$P10K_CONFIG" ]; then
  sed -i -e "s/typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=.*/typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=$p10k_os_icon_bg/" \
    -e "s/typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=.*/typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=$p10k_os_icon_fg/" \
    -e "s/typeset -g POWERLEVEL9K_DIR_BACKGROUND=.*/typeset -g POWERLEVEL9K_DIR_BACKGROUND=$p10k_main_bg/" \
    -e "s/typeset -g POWERLEVEL9K_DIR_FOREGROUND=.*/typeset -g POWERLEVEL9K_DIR_FOREGROUND=$p10k_main_fg/" \
    -e "s/typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=.*/typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$p10k_anchor_fg/" \
    -e "s/typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=.*/typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=$p10k_vcs_clean_bg/" \
    -e "s/typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=.*/typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=$p10k_vcs_modified_bg/" \
    -e "s/typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=.*/typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=$p10k_vcs_untracked_bg/" \
    -e "s/typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=.*/typeset -g POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND=$p10k_vcs_conflicted_bg/" \
    -e "s/typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=.*/typeset -g POWERLEVEL9K_VCS_LOADING_BACKGROUND=$p10k_vcs_loading_bg/" \
    -e "s/typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=.*/typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$p10k_exec_time_bg/" \
    -e "s/typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=.*/typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$p10k_exec_time_fg/" \
    -e "s/typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=.*/typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=$p10k_background_jobs_bg/" \
    -e "s/typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=.*/typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$p10k_background_jobs_fg/" \
    "$P10K_CONFIG"
fi

# --- Cava ---
CAVA_TEMPLATE="$HOME/.config/cava/config.template"
CAVA_CONFIG="$HOME/.config/cava/config"

sed -e "s/__gradient_1__/$cava_gradient_1/g" \
  -e "s/__gradient_2__/$cava_gradient_2/g" \
  -e "s/__gradient_3__/$cava_gradient_3/g" \
  -e "s/__foreground__/$cava_foreground/g" \
  -e "s/__background__/$cava_background/g" \
  "$CAVA_TEMPLATE" >"$CAVA_CONFIG"

# --- Reloads ---
killall -SIGUSR2 waybar
killall dunst && dunst &
source ~/.cache/ls_colors
/usr/bin/kill -SIGUSR1 $(pidof kitty)

# --- Notify ---
notify-send "Theme Changed" "Set to $name"
