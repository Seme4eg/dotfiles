#!/bin/sh
# source:
# https://github.com/justchokingaround/dotfiles/blob/main/rofi/scripts/rofi-gpt

INPUT=$(rofi -dmenu -theme-str '#entry { placeholder: "ask de robot"; }')
[ -z "$INPUT" ] && exit 1

zenity --progress --text="Waiting for an answer" --pulsate &
[ $? -eq 1 ] && exit 1

PID=$!

ANSWER=$(chatgpt -p api "${INPUT}")

kill $PID
zenity --info --text="$ANSWER"
