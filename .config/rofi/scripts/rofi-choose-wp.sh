#!/bin/sh

wp_dir="$HOME/Pictures/atmosphere/Wadim Kashin"

list_wps() {
  find "$wp_dir" -maxdepth 1 -type f -printf "%f\n" |
    while read wp; do
      echo -en "$wp\x00icon\x1f$wp_dir/$wp\n";
    done
}

rofi_dmenu() {
  rofi -dmenu -p "" -show-icons
}

wp=$( list_wps | rofi_dmenu )

[ ! -z $wp ] && change-theme -w "$wp_dir/$wp"
