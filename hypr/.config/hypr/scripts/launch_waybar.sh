#!/bin/bash

# Define the lock file path
LOCK_FILE="/tmp/waybar_lock"

# Check if the lock file exists
if [ -f "$LOCK_FILE" ]; then
    # If it exists, it means another instance is trying to run, so we exit.
    exit 0
fi

# Create the lock file
touch "$LOCK_FILE"

# This is a safety measure. It ensures the lock file is removed when this script exits.
trap 'rm -f "$LOCK_FILE"' EXIT

# Finally, launch Waybar
waybar &> /dev/null
