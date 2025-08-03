#!/bin/bash

if pgrep -x "wofi" > /dev/null; then
    killall wofi
else
    GDK_BACKEND=wayland wofi --show drun
fi

