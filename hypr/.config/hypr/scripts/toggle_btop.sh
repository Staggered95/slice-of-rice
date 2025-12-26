if pgrep -x "btop" > /dev/null; then
    # If it is, kill it
    killall btop
else
    kitty -e btop
fi
