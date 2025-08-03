#!/bin/bash

MAX_LEN=25
PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ]; then
    TITLE=$(playerctl metadata title)
    
    # Check if the title is longer than MAX_LEN
    if [ "${#TITLE}" -gt "$MAX_LEN" ]; then
        # If yes, truncate it and add an ellipsis
        echo "$(echo "$TITLE" | cut -c 1-$MAX_LEN)..."
    else
        # If no, just print the full title
        echo "$TITLE"
    fi
elif [ "$PLAYER_STATUS" = "Paused" ]; then
    echo "Music Paused"
else
    echo "" # Print nothing if no music is playing
fi