#!/bin/bash

# --- Main Configuration ---
THEME_FAMILIES="Catppuccin\nEverforest\nGruvbox"
THEME_VARIANTS="Dark\nLight"

# --- Wofi Menus ---
# 1. Select Theme Family
SELECTED_FAMILY=$(echo -e "$THEME_FAMILIES" | wofi -dmenu -p "Select Theme Family")
if [ -z "$SELECTED_FAMILY" ]; then
    exit 0
fi

# 2. Select Theme Variant
SELECTED_VARIANT=$(echo -e "$THEME_VARIANTS" | wofi -dmenu -p "Select Variant")
if [ -z "$SELECTED_VARIANT" ]; then
    exit 0
fi

# --- Execution ---
# Sanitize names for use in filenames (e.g., "Catppuccin" -> "catppuccin")
FAMILY_LOWER=$(echo "$SELECTED_FAMILY" | tr '[:upper:]' '[:lower:]')
VARIANT_LOWER=$(echo "$SELECTED_VARIANT" | tr '[:upper:]' '[:lower:]')

# Construct the theme key (e.g., "catppuccin_dark")
CURRENT_THEME="${FAMILY_LOWER}_${VARIANT_LOWER}"
THEME_ENGINE_SCRIPT="$HOME/.config/hypr/scripts/apply-theme.sh"
THEMES_DB="$HOME/.config/hypr/themes.json"

# Check if the theme key exists in the JSON database
if jq -e ".[\"$CURRENT_THEME\"]" "$THEMES_DB" > /dev/null; then
    # If it exists, apply the theme using the engine script
    sh "$THEME_ENGINE_SCRIPT" "$CURRENT_THEME"
    
    # Update the pointer file for the next login
    echo "$CURRENT_THEME" > "$HOME/.config/hypr/themes/current_theme.state"
else
    notify-send "Theme Error" "Theme '$SELECTED_FAMILY $SELECTED_VARIANT' not found in database." -u critical
fi