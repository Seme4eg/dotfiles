#!/usr/bin/env zsh

# --- Wayland setup ---

GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia

# qutebrowser vars
QT_SCALE_FACTOR=1
QT_QPA_PALTFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland

# bemenu vars
BEMENU_BACKEND=wayland

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  # exec startx

  export SDL_VIDEODRIVER=wayland
  # export MOZ_ENABLE_WAYLAND=1 # just for tests or in case mine wont work
  # exec Hyprland > /dev/null
  # exec awesome
fi
