#!/bin/bash

# Directory where screenshots will be saved
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Base filename with timestamp
BASE_FILENAME="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S')"
FULLSCREEN_FILENAME="${BASE_FILENAME}_full.png"
REGION_FILENAME="${BASE_FILENAME}_region.png"

# Function to take a full screenshot
take_full_screenshot() {
  grim "$FULLSCREEN_FILENAME"
  wl-copy < "$FULLSCREEN_FILENAME"
  notify-send "Full Screenshot Taken" "Saved to $FULLSCREEN_FILENAME and copied to clipboard."
}

# Function to take a regional screenshot
take_region_screenshot() {
  # Use slurp to select a region, allowing cancellation with Esc
  # The -d flag enables the cancel feature.
  GEOMETRY=$(slurp -d -b "#1e1e2ecc")

  # If slurp was cancelled (GEOMETRY is empty), exit the function.
  if [ -z "$GEOMETRY" ]; then
      return 1
  fi

  # Take the screenshot of the selected region
  grim -g "$GEOMETRY" "$REGION_FILENAME"

  # Copy the screenshot to the clipboard
  wl-copy < "$REGION_FILENAME"

  # Send a notification
  notify-send "Region Screenshot Taken" "Saved to $REGION_FILENAME and copied to clipboard."
  return 0
}

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --full)
      take_full_screenshot
      exit 0
      ;;
    --region)
      take_region_screenshot
      exit 0
      ;;
    *)
      # Default to region screenshot if no valid flag is provided
      take_region_screenshot
      exit 0
      ;;
  esac
done

# Default to region screenshot if no arguments are provided
take_region_screenshot
exit 0