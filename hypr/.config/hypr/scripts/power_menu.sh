#!/bin/bash

# Check if Wofi is already running
if pgrep -x "wofi" > /dev/null; then
    # If it is, kill it
    killall wofi
else
    # If it's not, show the power menu
    options="⏻ Shutdown\n Reboot\n󰗼 Logout\n Lock\n Suspend"

    selected=$(echo -e "$options" | wofi -dmenu --style ~/.config/wofi/style_powermenu.css -p "Power Menu")
    
    case $selected in
        "⏻ Shutdown")
            systemctl poweroff
            ;;
        " Reboot")
            systemctl reboot
            ;;
        "󰗼 Logout")
            hyprctl dispatch exit
            ;;
        " Lock")
            sh ~/.config/hypr/scripts/lock.sh
            ;;
        " Suspend")
            systemctl suspend
            ;;
    esac
fi