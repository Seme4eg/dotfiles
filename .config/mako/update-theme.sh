#!/bin/sh

. "${HOME}/.cache/wal/colors.sh"

conffile="$XDG_CONFIG_HOME/mako/config"

# Associative array, color name -> color code.
declare -A colors
colors=(
    ["background-color"]="${background}89"
    ["text-color"]="$foreground"
    ["border-color"]="$color13"
)

for color_name in "${!colors[@]}"; do
  # replace first occurance of each color in config file
  sed -i "0,/^$color_name.*/{s//$color_name=${colors[$color_name]}/}" $conffile
done

sed -i "s/\(^format=.\{1,10\}color=\"\).\{4,9\}\(\".\{30,60\}color=\"\).\{4,9\}\(\".*\)/\1${color3}\2${color8}\3/" $conffile

sh $XDG_CONFIG_HOME/mako/reload.sh
