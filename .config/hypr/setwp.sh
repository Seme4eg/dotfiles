#!/usr/bin/env bash
wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)

[[ $prev_wallpaper ]] &&
  hyprctl hyprpaper unload "$prev_wallpaper"
# pkill hyprpaper
# hyprpaper &
# sleep 0.1
hyprctl hyprpaper preload "$wp"
hyprctl hyprpaper wallpaper "eDP-1,$wp"

prev_wallpaper=$wp
