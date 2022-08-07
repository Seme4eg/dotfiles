#!/usr/bin/env bash

###############################################################################
#                       this thing crashes too often...                       #
###############################################################################

wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)

[[ $prev_wallpaper ]] &&
  hyprctl hyprpaper unload "$prev_wallpaper"

[[ -z $(pgrep hyprpaper) ]] && hyprpaper &

# pkill hyprpaper
# hyprpaper &
# sleep 0.1
hyprctl hyprpaper preload "$wp"
hyprctl hyprpaper wallpaper "eDP-1,$wp"

prev_wallpaper=$wp
