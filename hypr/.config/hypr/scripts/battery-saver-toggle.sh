#!/bin/bash
STATE_FILE="/tmp/power_toggle.state"
MAIN_SCRIPT_PATH="/home/Shubham/.config/hypr/scripts/battery-saver.sh"

if [ -f "$STATE_FILE" ]; then
    "$MAIN_SCRIPT_PATH" --off
else
    "$MAIN_SCRIPT_PATH" --on
fi
