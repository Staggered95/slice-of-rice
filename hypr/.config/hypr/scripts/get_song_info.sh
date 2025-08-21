#!/bin/bash

PLAYER_STATUS=$(playerctl status 2>/dev/null)

if [ "$PLAYER_STATUS" = "Playing" ] || [ "$PLAYER_STATUS" = "Paused" ]; then
  # Get the player name
  PLAYER_NAME=$(playerctl metadata --format "{{ playerName }}")

  # Set a default icon
  ICON="🎵"

  # Choose an icon based on the player name
  if [ "$PLAYER_NAME" = "spotify" ]; then
    ICON="󰓇"
  elif [ "$PLAYER_NAME" = "firefox" ]; then
    ICON=""
  elif [ "$PLAYER_NAME" = "vivaldi" ]; then
    ICON=""
  elif [ "$PLAYER_NAME" = "io" ]; then
    ICON=""
  else
    #ICON="" # <-- The new default/fallback icon
    ICON=""
  fi

  # Get the song info and combine it with the chosen icon
  INFO=$(playerctl metadata --format "{{ title }}")
  if [ -z "$INFO" ] || [ "$INFO" = " - " ]; then
    # If it's empty, just show the icon and status
    echo "$ICON $(playerctl status)"
  else
    # If it has info, show the icon and the info
    echo "$ICON  ${INFO}" | cut -c 1-50 # Truncate to 50 chars
  fi
else
  echo ""
fi
