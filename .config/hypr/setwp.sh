#!/usr/bin/env bash

wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)

[[ $prev_wallpaper ]] && hyprctl hyprpaper unload "$prev_wallpaper"
# remove this line if you deside to move hyprpaper to soystemd service again
[[ -z $(pgrep hyprpaper) ]] && hyprpaper &

hyprctl hyprpaper preload "$wp"
hyprctl hyprpaper wallpaper "eDP-1,$wp"

prev_wallpaper=$wp
