#!/bin/bash

# We'll identify the window by a unique part of its command line.
# Let's give it a unique title to make it easy to find.
UNIQUE_TITLE="kitty-htop-toggle"

# Use pgrep -f to check if a kitty process with our unique title is running.
# The "-f" flag searches the entire command line, which is key.
if pgrep -f "kitty --title $UNIQUE_TITLE" > /dev/null; then
    # If it's running, use pkill -f to kill the process by the same command line.
    pkill -f "kitty --title $UNIQUE_TITLE"
else
    # If it's not running, launch it with the unique title.
    # The '&' runs it in the background so it doesn't block the script.
    kitty --title "$UNIQUE_TITLE" -e htop &
fi
