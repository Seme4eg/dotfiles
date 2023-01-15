#!/usr/bin/env bash

wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)

[[ $prev_wallpaper ]] && hyprctl hyprpaper unload "$prev_wallpaper"
[[ -z $(pgrep hyprpaper) ]] && hyprpaper &

hyprctl hyprpaper preload "$wp"
hyprctl hyprpaper wallpaper "eDP-1,$wp"

prev_wallpaper=$wp

# ... if the above won't work - fix your system
# as the shitty workaround:

# wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)
# configFile=~/.config/hypr/hyprpaper.conf

# pkill -9 hyprpaper

# > $configFile
# echo "preload = $wp" 1>> $configFile
# echo "wallpaper = eDP-1,$wp" 1>> $configFile

# hyprpaper &
