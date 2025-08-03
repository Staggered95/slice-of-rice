#!/bin/bash

# A script that calculates network speed by reading kernel stats directly.
# This is the most reliable method and has no external dependencies.

INTERFACE="wlp1s0" # Make sure this is your correct interface

# Get the initial byte counts
RX_BYTES_OLD=$(cat "/sys/class/net/${INTERFACE}/statistics/rx_bytes")
TX_BYTES_OLD=$(cat "/sys/class/net/${INTERFACE}/statistics/tx_bytes")

# Wait for one second
sleep 1

# Get the new byte counts
RX_BYTES_NEW=$(cat "/sys/class/net/${INTERFACE}/statistics/rx_bytes")
TX_BYTES_NEW=$(cat "/sys/class/net/${INTERFACE}/statistics/tx_bytes")

# Calculate the speed in bytes per second
RX_SPEED_Bps=$(( (RX_BYTES_NEW - RX_BYTES_OLD) ))
TX_SPEED_Bps=$(( (TX_BYTES_NEW - TX_BYTES_OLD) ))

# Function to format the speed into KB/s or MB/s
format_speed() {
    local speed_bps=$1
    if (( speed_bps > 1048576 )); then # More than 1 MB/s
        printf "%.2f MB/s" $(echo "$speed_bps / 1048576" | bc -l)
    elif (( speed_bps > 1024 )); then # More than 1 KB/s
        printf "%.2f KB/s" $(echo "$speed_bps / 1024" | bc -l)
    else
        printf "%d B/s" "$speed_bps"
    fi
}

# Format and print the output for Waybar
RX_FORMATTED=$(format_speed $RX_SPEED_Bps)
TX_FORMATTED=$(format_speed $TX_SPEED_Bps)

echo " ${RX_FORMATTED}"
