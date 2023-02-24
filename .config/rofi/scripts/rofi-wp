#!/bin/sh

wp_dir="$HOME/Pictures/wps/pc"

list_wps() {
  find "$wp_dir" -type f -printf "%P\n" |
    while read wp; do
      echo -en "$wp\x00icon\x1f$wp_dir/$wp\n";
    done
}

rofi_dmenu() {
  rofi -dmenu -show-icons -theme-str '#entry { placeholder: "Wallpaper to apply.."; }'
}

wp=$( list_wps | rofi_dmenu )

[ ! -z $wp ] && change-theme -w "$wp_dir/$wp"
