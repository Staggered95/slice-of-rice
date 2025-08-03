#!/bin-bash
cliphist list | head -n 60 | wofi --dmenu --style ~/.config/wofi/style_clipboard.css | cliphist decode | wl-copy
