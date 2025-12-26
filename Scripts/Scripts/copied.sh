
hyprctl dispatch workspace 1
kitty &
firefox &
sleep 1

hyprctl dispatch workspace 2
vscodium &
chromium &
sleep 1

hyprctl dispatch workspace 4
kitty -e bash -c "cd ~/YumeTunes && npm run dev -- --host" &
sleep 1

hyprctl dispatch togglespecialworkspace magic
thunar &
kitty -e bash -c "hi"


