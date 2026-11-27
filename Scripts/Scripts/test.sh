#!/usr/bin/env bash

LOG_FILE="$HOME/hdmi-diag-$(date +%Y%m%d-%H%M%S).log"

{
  echo "=== HDMI DIAGNOSTIC LOG ==="
  echo "Timestamp: $(date)"
  echo "Kernel: $(uname -r)"
  echo ""

  echo "=== 1. DRM CONNECTORS ==="
  for dir in /sys/class/drm/card*-*; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    status=$(cat "$dir/status" 2>/dev/null || echo "N/A")
    enabled=$(cat "$dir/enabled" 2>/dev/null || echo "N/A")
    dpms=$(cat "$dir/dpms" 2>/dev/null || echo "N/A")
    edid_size=$(wc -c <"$dir/edid" 2>/dev/null || echo "0")
    echo "$name | status=$status | enabled=$enabled | dpms=$dpms | edid_bytes=$edid_size"
  done
  echo ""

  echo "=== 2. HDMI-A-1 SUPPORTED MODES ==="
  if [ -f /sys/class/drm/card1-HDMI-A-1/modes ]; then
    cat /sys/class/drm/card1-HDMI-A-1/modes
  else
    echo "card1-HDMI-A-1/modes not found"
  fi
  echo ""

  echo "=== 3. HDMI-A-1 EDID DECODE (IF AVAILABLE) ==="
  if [ -s /sys/class/drm/card1-HDMI-A-1/edid ]; then
    if command -v edid-decode >/dev/null 2>&1; then
      edid-decode /sys/class/drm/card1-HDMI-A-1/edid
    else
      echo "EDID present ($(wc -c </sys/class/drm/card1-HDMI-A-1/edid) bytes), edid-decode not installed."
    fi
  else
    echo "No EDID data received from projector."
  fi
  echo ""

  echo "=== 4. HYPRLAND MONITORS ==="
  hyprctl monitors all 2>&1
  echo ""

  echo "=== 5. KERNEL DRM/AMDGPU/HDMI LOGS (LAST 60 LINES) ==="
  if journalctl -k -b --no-pager 2>/dev/null | grep -iE "amdgpu|drm|hdmi" | tail -n 60; then
    :
  else
    echo "Run with sudo or check dmesg manually if kernel logs are restricted."
  fi
} >"$LOG_FILE" 2>&1

echo "Saved diagnostic log to: $LOG_FILE"
