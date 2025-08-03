#!/bin/bash

# --- SCRIPT TO SET WALLPAPER AND SAVE IT TO THE CURRENT THEME ---

# --- Check for arguments ---
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/image [--lock|--pfp]"
    exit 1
fi

IMG_PATH="$1"
MODE="$2"

# --- Get the current theme name ---
# This reads the 'current_theme.sh' file to find the active theme script,
# then extracts the theme name (e.g., 'catppuccin' or 'everforest')
CURRENT_THEME=$(cat "$HOME/.config/hypr/themes/current_theme.state")
FILE_EXTENSION="${IMG_PATH##*.}"
MONITOR=$(hyprctl monitors | grep 'Monitor' | head -n 1 | awk '{print $2}')


# --- Main Logic ---
case $MODE in
    --lock)
        # Set the lockscreen background
        sed -i "s|path = .* # LOCK_WALL|path = $IMG_PATH # LOCK_WALL|g" ~/.config/hypr/hyprlock.conf
	    echo "$IMG_PATH" > "$HOME/.config/hypr/themes/lockpaper/${CURRENT_THEME}.lockpaper"
        notify-send "Lockscreen Changed" "New background set."
        ;;
    --pfp)
        # Set the profile picture
        sed -i "s|path = .* # AVATAR|path = $IMG_PATH # AVATAR|g" ~/.config/hypr/hyprlock.conf
        notify-send "Profile Picture Changed" "New avatar set."
        ;;
    *)
        if [[ "mp4|mov|mkv" =~ $FILE_EXTENSION ]]; then
            # --- IT'S A VIDEO ---
            # Kill other wallpaper daemons
            swww kill
    
            # Run mpvpaper
            mpvpaper -p -o "--loop-file=inf --no-audio" "$MONITOR" "$IMG_PATH"

        elif [[ "gif" =~ $FILE_EXTENSION ]]; then
            # --- IT'S A GIF ---
            # Kill other wallpaper daemons
            killall mpvpaper &> /dev/null
            # Start swww if not running
            if ! pgrep -x swww-daemon > /dev/null; then swww-daemon & &> /dev/null & sleep 0.5; fi
            # Set wallpaper with swww
            swww img "$IMG_PATH" --transition-type wipe
        else
            # --- IT'S A STATIC IMAGE ---
            # Kill other wallpaper daemons
            killall mpvpaper &> /dev/null
            # Start swww if not running
            if ! pgrep -x swww-daemon > /dev/null; then swww-daemon & &> /dev/null & sleep 0.5; fi
            # Set wallpaper with swww (it's better than hyprpaper)
            swww img "$IMG_PATH" --transition-type grow
        fi
        

        # 3. Save the wallpaper path to the current theme's state file
        if [ -n "$CURRENT_THEME" ]; then
            echo "$IMG_PATH" > "$HOME/.config/hypr/themes/wallpaper/${CURRENT_THEME}.wallpaper"
            notify-send "Wallpaper Changed" "Set for '$CURRENT_THEME' theme."
        else
            notify-send "Wallpaper Changed" "Note: No active theme found."
        fi
        ;;
esac
