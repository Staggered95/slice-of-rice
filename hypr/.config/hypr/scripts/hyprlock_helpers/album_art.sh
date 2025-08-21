#!/bin/bash

# --- Check Player Status First ---
PLAYER_STATUS=$(playerctl status 2>/dev/null)
if [ -z "$PLAYER_STATUS" ] || [ "$PLAYER_STATUS" = "Stopped" ]; then
    exit 0 # Exit silently if no player is active
fi

# --- Configuration ---
CACHE_DIR="$HOME/.cache/hyprlock_album_art"
CROPPED_DIR="$CACHE_DIR/cropped" # New directory for consistent, square art
BLURRED_DIR="$CACHE_DIR/blurred"
mkdir -p "$CACHE_DIR" "$CROPPED_DIR" "$BLURRED_DIR"
DEFAULT_ICON="$HOME/Downloads/pfp.jpg"
ART_SIZE="300x300" # Define the desired square size for the main art
BLUR_SIZE="380x120" # Define the size for the blurred background

# --- Get Info ---
PLAYER=$(playerctl -l 2>/dev/null | head -n 1)

if [ -z "$PLAYER" ]; then
    exit 0
fi

PLAYER_STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
if [ -z "$PLAYER_STATUS" ] || [ "$PLAYER_STATUS" = "Stopped" ]; then
    exit 0
fi

ART_URL=$(playerctl -p "$PLAYER" metadata mpris:artUrl 2>/dev/null || echo "")

# --- Logic ---
if [ -z "$ART_URL" ]; then
    # If there's a player but no art, use the default icon
    SOURCE_ART="$DEFAULT_ICON"
else
    if [[ "$ART_URL" == "file://"* ]]; then
        # It's a local file, decode the path and use it directly
        SOURCE_ART="${ART_URL/file:\/\//}"
    else
        # It's a web URL, download and cache it
        SOURCE_ART="$CACHE_DIR/$(echo "$ART_URL" | md5sum | awk '{print $1}').jpg"
        if [ ! -f "$SOURCE_ART" ]; then
            wget -q -O "$SOURCE_ART" "$ART_URL"
        fi
    fi
fi

# --- Image Processing Function ---
# A function to resize and crop images to avoid repeating code
process_image() {
    local source_file="$1"
    local dest_file="$2"
    local size="$3"
    
    # Only process if the destination file doesn't exist, or if the source is a local file
    # (local files might change content without changing name)
    if [ ! -f "$dest_file" ] || [[ "$ART_URL" == "file://"* ]]; then
        magick "$source_file" -resize "$size^" -gravity center -extent "$size" "$dest_file"
    fi
}

# --- Output Logic ---
case "$1" in
    --art)
        CROPPED_ART="$CROPPED_DIR/$(basename "$SOURCE_ART")"
        process_image "$SOURCE_ART" "$CROPPED_ART" "$ART_SIZE"
        echo "$CROPPED_ART"
        ;;
    --blur)
        BLURRED_ART="$BLURRED_DIR/$(basename "$SOURCE_ART")"
        # Add blur effect to the processing command for this case
        if [ ! -f "$BLURRED_ART" ] || [[ "$ART_URL" == "file://"* ]]; then
             magick "$SOURCE_ART" -blur 0x7 -resize "$BLUR_SIZE^" -gravity center -extent "$BLUR_SIZE" "$BLURRED_ART"
        fi
        echo "$BLURRED_ART"
        ;;
    *)
        # Default action is the same as --art
        CROPPED_ART="$CROPPED_DIR/$(basename "$SOURCE_ART")"
        process_image "$SOURCE_ART" "$CROPPED_ART" "$ART_SIZE"
        echo "$CROPPED_ART"
        ;;
esac