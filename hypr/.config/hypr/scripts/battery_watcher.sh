#!/bin/bash

# --- Configuration ---
BATTERY_LOW_THRESHOLD=20
BRIGHTNESS_LOW="15%"
BATTERY="BAT0"
AC_ADAPTER="AC0"
BRIGHTNESS_SAVE_FILE="/tmp/previous_brightness.val"

# --- Script Logic ---
while true; do
    BATTERY_LEVEL=$(cat "/sys/class/power_supply/${BATTERY}/capacity")
    AC_STATUS=$(cat "/sys/class/power_supply/${AC_ADAPTER}/online")

    if [ "$AC_STATUS" -eq 1 ]; then
        # --- PLUGGED IN ---
        # Set CPU to performance
        if [ "$(cpupower frequency-info --governor)" != "performance" ]; then
            sudo cpupower frequency-set -g performance
        fi
        # Restore brightness if we have a saved value
        if [ -f "$BRIGHTNESS_SAVE_FILE" ]; then
            brightnessctl set $(cat "$BRIGHTNESS_SAVE_FILE")
            rm "$BRIGHTNESS_SAVE_FILE"
        fi
    else
        # --- ON BATTERY ---
        if [ "$BATTERY_LEVEL" -le "$BATTERY_LOW_THRESHOLD" ]; then
            # Battery is LOW, dim the screen and set powersave
            if ! [ -f "$BRIGHTNESS_SAVE_FILE" ]; then
                # Save the current brightness level before dimming
                brightnessctl get > "$BRIGHTNESS_SAVE_FILE"
                brightnessctl set "$BRIGHTNESS_LOW"
                sudo cpupower frequency-set -g powersave
                notify-send "Low Battery: ${BATTERY_LEVEL}%" "Power saving enabled." -u critical
            fi
        else
            # Battery is NOT low, ensure CPU is set to powersave
            if [ "$(cpupower frequency-info --governor)" != "powersave" ]; then
                sudo cpupower frequency-set -g powersave
            fi
            # Restore brightness if it was previously dimmed
            if [ -f "$BRIGHTNESS_SAVE_FILE" ]; then
                brightnessctl set $(cat "$BRIGHTNESS_SAVE_FILE")
                rm "$BRIGHTNESS_SAVE_FILE"
                notify-send "Battery Normal: ${BATTERY_LEVEL}%" "Exiting power-saving mode." -u low
            fi
        fi
    fi

    sleep 60
done
