export GOPATH=$HOME/go
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state
export PNPM_HOME=$HOME/.pnpm

typeset -U path PATH
path=(
  $HOME/.local/bin
  $GOPATH/bin
  $XDG_CONFIG_HOME/emacs/bin # $EMACSDIR? not defined
  $XDG_CONFIG_HOME/rofi/scripts
  $PNPM_HOME
  $path
)
export PATH

export EDITOR="emacsclient -c"
export VISUAL="emacsclient -c -a emacs"
export TERMINAL=foot
export BROWSER=librewolf

export MAKEFLAGS="-j$(nproc)"

export PASSWORD_STORE_DIR=$XDG_DATA_HOME/password-store

export LSP_USE_PLISTS=true

# zsh-vi-mode
# https://github.com/jeffreytse/zsh-vi-mode/issues/24#issuecomment-873029329
ZVM_INIT_MODE=sourcing # <- needed BEFORE zvm gets sourced
# Do the initialization when the script is sourced (i.e. Initialize instantly)
ZVM_LAZY_KEYBINDINGS=false

## History
HISTFILE="$XDG_CACHE_HOME/zhistory"
HISTSIZE=100000 # Max events to store in internal history.
SAVEHIST=100000 # Max events to store in history file.

setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Remove old events if new event is a duplicate
setopt HIST_FIND_NO_DUPS      # Do not display a previously found event.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS      # Do not write a duplicate event to the history file.
