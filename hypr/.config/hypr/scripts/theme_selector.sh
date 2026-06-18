#!/bin/bash

# --- File Paths ---
THEMES_DB="$HOME/.config/hypr/themes.json"
THEME_ENGINE_SCRIPT="$HOME/.config/hypr/scripts/apply-theme.sh"
STATE_FILE="$HOME/.config/hypr/themes/current_theme.state"

if pgrep -x "wofi" >/dev/null; then
  # If Wofi is running, kill it (acts as a toggle)
  killall wofi
  exit 0
fi

# Ensure the database exists
if [ ! -f "$THEMES_DB" ]; then
  notify-send "Theme Error" "themes.json not found!" -u critical
  exit 1
fi

# --- 1. Dynamically get Theme Families ---
# Extracts the base family name (everything before the first '_'), removes duplicates, and capitalizes the first letter.
THEME_FAMILIES=$(jq -r 'keys[]' "$THEMES_DB" | awk -F'_' '{print $1}' | sort -u | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

SELECTED_FAMILY=$(echo -e "$THEME_FAMILIES" | wofi -dmenu -p "Select Theme Family")
if [ -z "$SELECTED_FAMILY" ]; then
  exit 0
fi

FAMILY_LOWER=$(echo "$SELECTED_FAMILY" | tr '[:upper:]' '[:lower:]')

# --- 2. Determine Variants ---
# Find all keys in themes.json that belong to the selected family (exact match or start with "family_")
AVAILABLE_KEYS=$(jq -r "keys[] | select(. == \"$FAMILY_LOWER\" or startswith(\"${FAMILY_LOWER}_\"))" "$THEMES_DB")
KEY_COUNT=$(echo "$AVAILABLE_KEYS" | wc -w)

if [ "$KEY_COUNT" -eq 0 ]; then
  notify-send "Theme Error" "No configuration found for '$SELECTED_FAMILY'." -u critical
  exit 1
elif [ "$KEY_COUNT" -eq 1 ]; then
  # If only one configuration exists (e.g., just "dracula"), skip the variant menu
  CURRENT_THEME="$AVAILABLE_KEYS"
else
  # If multiple exist (e.g., "everforest_dark", "everforest_light"), extract the variants and prompt
  VARIANTS=$(echo "$AVAILABLE_KEYS" | sed "s/^${FAMILY_LOWER}_//I" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
  SELECTED_VARIANT=$(echo -e "$VARIANTS" | wofi -dmenu -p "Select Variant")

  if [ -z "$SELECTED_VARIANT" ]; then
    exit 0
  fi

  VARIANT_LOWER=$(echo "$SELECTED_VARIANT" | tr '[:upper:]' '[:lower:]')
  CURRENT_THEME="${FAMILY_LOWER}_${VARIANT_LOWER}"
fi

# --- 3. Execution ---
# Check if the finalized theme key exists in the JSON database
if jq -e ".[\"$CURRENT_THEME\"]" "$THEMES_DB" >/dev/null; then

  # --- THEME ROUTER ---
  if [ "$CURRENT_THEME" == "ayaka" ]; then
    # Route to the dedicated Ayaka script
    sh "$HOME/.config/hypr/scripts/apply-ayaka.sh" "$CURRENT_THEME"
  else
    # Apply standard themes using the main engine script
    sh "$THEME_ENGINE_SCRIPT" "$CURRENT_THEME"
  fi

  # Update the pointer file for the next login (ensure directory exists first)
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$CURRENT_THEME" >"$STATE_FILE"
else
  notify-send "Theme Error" "Theme '$CURRENT_THEME' not found in database." -u critical
fi

