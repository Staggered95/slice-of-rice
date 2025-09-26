#!/bin/bash
# setup_monitors.sh

# Get the name of the first connected external monitor
EXTERNAL_MONITOR=$(hyprctl monitors all | grep "Monitor" | grep -v "eDP-1" | awk '{print $2}')
echo $EXTERNAL_MONITOR

# If no external monitor is connected, do nothing
if [ -z "$EXTERNAL_MONITOR" ]; then
  echo "No external monitor detected."
  # Fallback to primary-only mode if no external is found
  hyprctl keyword monitor "eDP-1, preferred, 0x0, 1"
  exit 0
fi

# The mode you want to apply, e.g., "extended-right"
MODE=$1

case $MODE in
"extended-right")
  hyprctl keyword monitor "eDP-1, preferred, 0x0, 1"
  hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,1920x0,1"
  ;;
"extended-left")
  # Assuming the external monitor is 1920px wide
  hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,0x0,1"
  hyprctl keyword monitor "eDP-1, preferred, 1920x0, 1"
  ;;
"mirror")
  hyprctl keyword monitor "eDP-1, preferred, 0x0, 1"
  hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,auto,1,mirror,eDP-1"
  ;;
"external-only")
  hyprctl keyword monitor "eDP-1,disable"
  hyprctl keyword monitor "$EXTERNAL_MONITOR,preferred,auto,1"
  ;;
"primary-only")
  hyprctl keyword monitor "eDP-1, preferred, 0x0, 1"
  hyprctl keyword monitor "$EXTERNAL_MONITOR,disable"
  ;;
*)
  echo "Usage: $0 [extended-right|extended-left|mirror|external-only|primary-only]"
  exit 1
  ;;
esac
