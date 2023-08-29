#!/usr/sh

# NOTE: check path in case you change it
cursor_path=$HOME/Documents/stuff/arch_cursors
files=$(ls $cursor_path | grep -E '.*\.tar..z$')
# Set $IFS to eliminate whitespace in pathnames.
IFS="$(printf '\n\t')"
DIR=$HOME/.icons

[ ! -d "$DIR" ] && mkdir $DIR

for file in $files; do
  echo "Extracting $file .."
  tar xf "$cursor_path/$file" -C $DIR
done
