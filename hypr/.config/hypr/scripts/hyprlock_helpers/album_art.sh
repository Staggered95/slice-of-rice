#!/bin/bash

# --- Check Player Status First ---
PLAYER_STATUS=$(playerctl status 2>/dev/null)
if [ -z "$PLAYER_STATUS" ] || [ "$PLAYER_STATUS" = "Stopped" ]; then
    exit 0 # Exit silently if no player is active
fi

# --- Configuration ---
CACHE_DIR="$HOME/.cache/hyprlock_album_art"
BLURRED_DIR="$CACHE_DIR/blurred"
mkdir -p "$CACHE_DIR" "$BLURRED_DIR"
DEFAULT_ICON="$HOME/Downloads/pfp.jpg"

# --- Get Info ---
ART_URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

# --- Logic ---
if [ -z "$ART_URL" ]; then
    # If there's a player but no art, use the default icon
    FILENAME="$DEFAULT_ICON"
else
    # Download art if it doesn't exist
    FILENAME="$CACHE_DIR/$(echo "$ART_URL" | md5sum | awk '{print $1}').jpg"
    if [ ! -f "$FILENAME" ]; then
        wget -q -O "$FILENAME" "$ART_URL"
    fi
fi

# Decide what to output based on the first argument
case "$1" in
    --art)
        echo "$FILENAME"
        ;;
    --blur)
        BLURRED_FILENAME="$BLURRED_DIR/$(basename "$FILENAME")"
        if [ ! -f "$BLURRED_FILENAME" ]; then
            magick "$FILENAME" -blur 0x7 -resize '380x120^' -gravity center -extent 380x120 "$BLURRED_FILENAME"
        fi
        echo "$BLURRED_FILENAME"
        ;;
    *)
        echo "$FILENAME"
        ;;
esac
