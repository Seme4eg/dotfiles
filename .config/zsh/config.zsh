# Only XDG_RUNTIME_DIR is set by default through pam_systemd(8). It is up to the
# user to explicitly define the other variables according to the specification
# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

export EDITOR="emacsclient -c"
export VISUAL="emacsclient -c -a emacs"
export TERMINAL=foot
export BROWSER=librewolf

export MAKEFLAGS="-j$(nproc)"

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

# --- ~/ cleanup (https://wiki.archlinux.org/title/XDG_Base_Directory) ---
export PASSWORD_STORE_DIR=$XDG_DATA_HOME/password-store
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
# or run with the --extensions-dir flag, such as code --extensions-dir
# "$XDG_DATA_HOME/vscode". This is documented and probably will not break as
# unexpectedly, as it is has other use cases.
export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc" # :"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
export ADB_KEYS_PATH="/home/earthian/Documents/tech/android/adbkeys/adbkey"
export PNPM_HOME=$XDG_DATA_HOME/pnpm

# ---

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
