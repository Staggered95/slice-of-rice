#!/usr/bin/env bash

# Power Toggle Script for Hyprland (AMD EPP) - Final Polished Version
#
# Usage:
#   ./power-toggle.sh --on    - Activates maximum power saving
#   ./power-toggle.sh --off   - Activates maximum performance

# --- CONFIGURATION ---
STATE_FILE="/tmp/power_toggle.state"

# --on (Powersave) Settings
BRIGHTNESS_ON="15%"

# --off (Performance) Settings
BRIGHTNESS_OFF="60%"

# --- SERVICE MANAGEMENT ---
# Use base names only (e.g., "postgresql", not "postgresql.service")
SYSTEM_SERVICES_TO_STOP=(
  "warp-svc"
  "mariadb"
  "postgresql"
)
USER_SERVICES_TO_STOP=(
  "anime_organizer.timer"
  "syncthing"
)

# --- SCRIPT LOGIC ---

notify() {
  dunstify -u low -h string:x-dunst-stack-tag:powertoggle "⚡ Power Saver" "$1"
}

notify "Changing..."

MONITOR_NAME=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .name')
CPU_BOOST_PATH="/sys/devices/system/cpu/cpufreq/boost"

# --- MODE FUNCTIONS ---

activate_save_mode() {
  if [ -f "$STATE_FILE" ]; then
    echo "Power saving is already ON."
    exit 0
  fi
  echo "Activating powersave mode..."

  for service_base in "${SYSTEM_SERVICES_TO_STOP[@]}"; do
    sudo systemctl stop "${service_base}.socket" 2>/dev/null
    sudo systemctl stop "${service_base}.service" 2>/dev/null
  done
  for service in "${USER_SERVICES_TO_STOP[@]}"; do systemctl --user stop "$service" 2>/dev/null; done

  hyprctl keyword animations:enabled 0
  hyprctl keyword decoration:blur:enabled 0
  hyprctl eval 'hl.config({ animations = { enabled = false }, decoration = { blur = { enabled = false }, active_opacity = 1.0, inactive_opacity = 1.0, fullscreen_opacity = 1.0 } })'
  brightnessctl set "$BRIGHTNESS_ON"

  # CPU Powersave Sequence
  echo "0" | sudo tee "$CPU_BOOST_PATH" >/dev/null
  echo "powersave" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
  sleep 0.1
  echo "power" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null 2>/dev/null

  touch "$STATE_FILE"
  notify "ACTIVATED"
  echo "Done."
}

deactivate_save_mode() {
  if [ ! -f "$STATE_FILE" ]; then
    echo "Power saving is already OFF."
    exit 0
  fi
  echo "Activating performance mode..."

  for service_base in "${SYSTEM_SERVICES_TO_STOP[@]}"; do
    sudo systemctl start "${service_base}.socket" 2>/dev/null
    sudo systemctl start "${service_base}.service" 2>/dev/null
  done
  for service in "${USER_SERVICES_TO_STOP[@]}"; do systemctl --user start "$service" 2>/dev/null; done

  hyprctl keyword animations:enabled 1
  hyprctl keyword decoration:blur:enabled 1
  hyprctl eval 'hl.config({ animations = { enabled = true }, decoration = { blur = { enabled = true }, active_opacity = 0.75, inactive_opacity = 0.75 } })'
  brightnessctl set "$BRIGHTNESS_OFF"

  # CPU Performance Sequence
  echo "1" | sudo tee "$CPU_BOOST_PATH" >/dev/null
  echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
  sleep 0.1
  echo "balance_performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference >/dev/null 2>/dev/null

  rm "$STATE_FILE"
  notify "DEACTIVATED"
  echo "Done."
}

# --- MAIN LOGIC ---
case "$1" in
--on)
  activate_save_mode
  ;;
--off)
  deactivate_save_mode
  ;;
*)
  echo "Usage: $0 --on | --off"
  exit 1
  ;;
esac
