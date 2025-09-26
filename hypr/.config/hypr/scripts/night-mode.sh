#!/bin/bash

# Define the location for a state file
STATE_FILE="/tmp/night_mode.state"

# Define the icons
ICON_SUN=""   # Sun icon for when Night Mode is OFF
ICON_MOON=""  # Moon icon for when Night Mode is ON

# Check if the state file exists
if [ -f "$STATE_FILE" ]; then
    # --- Night mode is ON, so TURN IT OFF ---
    hyprctl hyprsunset identity > /dev/null 2>&1
    rm "$STATE_FILE" # Delete the state file
    echo "{\"text\": \"$ICON_SUN\", \"class\": \"off\", \"tooltip\": \"Night Mode: Off\"}"
else
    # --- Night mode is OFF, so TURN IT ON ---
    hyprctl hyprsunset temperature 3500 > /dev/null 2>&1
    touch "$STATE_FILE" # Create the state file
    echo "{\"text\": \"$ICON_MOON\", \"class\": \"on\", \"tooltip\": \"Night Mode: On\"}"
fi
