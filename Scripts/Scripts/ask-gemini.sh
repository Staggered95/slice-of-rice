#!/bin/bash

# Use Wofi to get a prompt from the user
PROMPT=$(wofi --dmenu --prompt " Ask Gemini")

# If the user entered something (didn't cancel), then run the chat script
if [ -n "$PROMPT" ]; then
    # Open a new terminal window (foot is a common choice for Hyprland)
    # It runs the script and then waits for a keypress before closing.
    foot sh -c "~/Scripts/gemini-chat.sh \"$PROMPT\"; read"
fi
