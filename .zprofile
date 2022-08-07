#!/usr/bin/env bash

# Defer to .profile
[[ -f ~/.profile  ]] && . ~/.profile

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  # exec startx

  export SDL_VIDEODRIVER=wayland
  # export MOZ_ENABLE_WAYLAND=1 # just for tests or in case mine wont work
  # exec Hyprland > /dev/null
  # exec awesome
fi
