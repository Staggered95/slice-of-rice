#!/bin/bash

# --- Variables ---
REC_DIR="$HOME/Videos/Screenrecords"
mkdir -p "$REC_DIR"
FILENAME="$REC_DIR/$(date +'%Y-%m-%d_%H-%M-%S').mp4"
PID_FILE="/tmp/screenrecord.pid"

# --- Logic ---
# Check if a recording is already in progress
if [ -f "$PID_FILE" ]; then
    # Stop the recording
    kill -INT $(cat "$PID_FILE")
    rm "$PID_FILE"
    notify-send "Screen Recording Stopped" "Saved to $REC_DIR"
    exit 0
fi

# Determine recording mode based on the first argument
MODE=$1
GEOMETRY=""

case $MODE in
    full)
        # Fullscreen recording
        GEOMETRY=""
        ;;
    area)
        # Area selection with cancel option
        GEOMETRY=$(slurp -d -b "#1e1e2ecc") # -d allows Esc to cancel
            
        # If slurp was cancelled, exit the script
        if [ -z "$GEOMETRY" ]; then
            exit 0
        fi
        ;;
    window)
        # Active window selection
        GEOMETRY=$(hyprctl activewindow | grep 'at:' | cut -d' ' -f2 | sed 's/,/ /')
        SIZE=$(hyprctl activewindow | grep 'size:' | cut -d' ' -f2 | sed 's/,/x/')
        GEOMETRY="$GEOMETRY $SIZE"
        ;;
    *)
        echo "Usage: $0 [full|area|window]"
        exit 1
        ;;
esac

# Start the recording
notify-send "Screen Recording Started" "Mode: $MODE. Press the keybind again to stop."

# Use -g for geometry and save the PID
wf-recorder -a -g "$GEOMETRY" -f "$FILENAME" &
echo $! > "$PID_FILE"
