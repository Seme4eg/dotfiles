export PATH="$HOME/.emacs.d/bin:$HOME/.npm-global/bin:$PATH"

export GDK_SCALE=2
export GDK_DPI_SCALE=0.5

export QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_SCALE_FACTOR=1.2

export LIBVA_DRIVER_NAME=vdpau

# Make sure `ls` collates dotfiles first (for dired)
# export LC_COLLATE="C"

# Many build scripts expect CC to contain the compiler command
# export CC="gcc"

# We're in Emacs, yo
# export VISUAL=emacsclient
# export EDITOR="$VISUAL"

# Load .bashrc to get login environment
[ -f ~/.bashrc ] && . ~/.bashrc
