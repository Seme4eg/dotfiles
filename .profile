export PATH="$HOME/.emacs.d/bin:$HOME/.npm-global/bin:$PATH"

# Make sure `ls` collates dotfiles first (for dired)
# export LC_COLLATE="C"

# Many build scripts expect CC to contain the compiler command
# export CC="gcc"

# We're in Emacs, yo
# export VISUAL=emacsclient
# export EDITOR="$VISUAL"

# Load .bashrc to get login environment
[ -f ~/.bashrc ] && . ~/.bashrc

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
# BEMENU_SCALE=2
