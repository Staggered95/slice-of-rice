#!/bin/bash

# A unique ID for the notification
NOTIF_ID=9991
LOCK_FILE="/tmp/osd.lock"

# Prevent multiple instances
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"

# Function to send a notification
send_notification() {
    local type=$1
    local value=$2
    local icon=$3
    dunstify -h "int:value:$value" -h "string:x-dunst-stack-tag:osd" -i "$icon" "$type" -r "$NOTIF_ID" -t 2000
}

# Main script logic
case $1 in
    volume)
        # Volume control
        case $2 in
            up) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
            down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
            mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
        esac
        
        VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+%' | head -n 1 | tr -d '%')
        MUTE_STATUS=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
        
        # --- NEW ICON LOGIC FOR VOLUME ---
        if [ "$MUTE_STATUS" == "yes" ]; then
            ICON="audio-volume-muted-symbolic"
        elif (( VOLUME > 66 )); then
            ICON="audio-volume-high-symbolic"
        elif (( VOLUME > 33 )); then
            ICON="audio-volume-medium-symbolic"
        else
            ICON="audio-volume-low-symbolic"
        fi
        send_notification "Volume" "$VOLUME" "$ICON"
        ;;

    brightness)
        # Brightness control
        case $2 in
            up) brightnessctl set +5% ;;
            down) brightnessctl set 5%- ;;
        esac
        
        BRIGHTNESS=$(brightnessctl -m | awk -F, '{print $4}' | sed 's/%//')

        # --- NEW ICON LOGIC FOR BRIGHTNESS ---
        if (( BRIGHTNESS > 66 )); then
            ICON="display-brightness-high-symbolic"
        elif (( BRIGHTNESS > 33 )); then
            ICON="display-brightness-medium-symbolic"
        else
            ICON="display-brightness-low-symbolic"
        fi
        send_notification "Brightness" "$BRIGHTNESS" "$ICON"
        ;;
esac

# Remove the lock file
rm "$LOCK_FILE"