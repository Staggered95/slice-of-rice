
hyprctl dispatch workspace 1
kitty &
firefox &
sleep 3

hyprctl dispatch workspace 2
vscodium &
chromium &
sleep 2

hyprctl dispatch workspace 4
kitty -e bash -c "cd ~/YumeTunes && npm run dev -- --host" &
sleep 2

hyprctl dispatch togglespecialworkspace magic
thunar &
kitty -e bash -c "hi"



