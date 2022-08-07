#!/usr/bin/env bash

wp=$(find ~/Pictures/atmosphere/Wadim\ Kashin/ -type f | shuf -n 1)
configFile=~/.config/hypr/hyprpaper.conf

pkill -9 hyprpaper

> $configFile
echo "preload = $wp" 1>> $configFile
echo "wallpaper = eDP-1,$wp" 1>> $configFile

hyprpaper &
