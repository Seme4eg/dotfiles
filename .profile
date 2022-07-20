export PATH="$HOME/.bin:$HOME/.npm-global/bin:$PATH"

# Make sure `ls` collates dotfiles first (for dired)
export LC_COLLATE="C"

# Many build scripts expect CC to contain the compiler command
export CC="gcc"

# We're in Emacs, yo
export VISUAL=emacsclient
export EDITOR="$VISUAL"

# Load .bashrc to get login environment
[ -f ~/.bashrc ] && . ~/.bashrc

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  exec startx
fi
