#!/usr/sh

# NOTE: check path in case you change it
files=$(ls ~/apps/arch/cursors | grep -E '.*\.tar..z$')
# Set $IFS to eliminate whitespace in pathnames.
IFS="$(printf '\n\t')"

[ ! -d "$DIR" ] && mkdir ~/.icons # ~/.local/share/icons

for file in $files; do
  echo "Extracting $file .."
  tar xf "$file" -C ~/.icons # ~/.local/share/icons
done
