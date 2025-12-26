#!/bin/bash

THEME_DIR="/usr/share/sddm/themes/Elegant"
TARGET="$THEME_DIR/background.jpg"
TMP="/tmp/sddm-bg-blur.jpg"

SRC="$1"

if [[ -z "$SRC" ]]; then
  notify-send "SDDM Background" "No image selected"
  exit 1
fi

if [[ ! "$SRC" =~ \.(jpg|jpeg|JPG|JPEG)$ ]]; then
  notify-send "SDDM Background" "Please select a JPG image"
  exit 1
fi

# Create blurred + slightly dimmed image
magick "$SRC" -blur 0x20 -brightness-contrast -10x-5 "$TMP" || {
  notify-send "SDDM Background" "Image processing failed"
  exit 1
}

pkexec bash -c "
    cp \"$TMP\" \"$TARGET\" &&
    chown root:root \"$TARGET\" &&
    chmod 644 \"$TARGET\"
"

rm -f "$TMP"

if [[ $? -eq 0 ]]; then
  notify-send "SDDM Background" "Elegant background updated (blurred)"
else
  notify-send "SDDM Background" "Failed to update background"
fi
