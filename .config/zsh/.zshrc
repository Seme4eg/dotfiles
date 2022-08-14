###############################################################################
#                         Install 'grml-zsh-config' !                          #
###############################################################################

# stty stop undef # disable C-s to freeze terminal
# Nobody need flow control anymore. Troublesome feature.
#stty -ixon
setopt noflowcontrol
eval "$(zoxide init zsh)"

# --- Sourcing ---
. ~/.config/zsh/.zprofile
. ~/.config/zsh/aliases.zsh

# for now using powerlevel10k instead
# [ -f "~/.config/zsh/theming.zsh" ] && . "~/.config/zsh/theming.zsh"

if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
  # init-nvm.sh contents with bash_completion excluded and nvm dir changed
  [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.config/nvm"
  source /usr/share/nvm/nvm.sh
  source /usr/share/nvm/install-nvm-exec
fi

# --- Variables ---
# export PATH="$HOME/.emacs.d/bin:$HOME/.config/nvm/versions/node/v16.16.0/bin/:$PATH"
typeset -U path PATH
path=(~/.local/bin $path) # (~/.local/bin .. .. $path)
export PATH
export EDITOR=emacsclient
export TERMINAL=alacritty
export BROWSER=qutebrowser
# below ones seem to not work on wayland
# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5

# --- Antidote (https://getantidote.github.io/) ---

[[ -e ~/.config/zsh/.antidote ]] || git clone https://github.com/mattmc3/antidote.git ~/.config/zsh/.antidote
. ~/.config/zsh/.antidote/antidote.zsh
antidote load ~/.config/zsh/plugins

###############################################################################
#                               History settings                              #
###############################################################################

# Lines configured by zsh-newuser-install
HISTFILE=~/.cache/zsh/history

# enable history search (bound to C-k & C-j)

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -s '^p' up-line-or-beginning-search
bindkey -s '^n' down-line-or-beginning-search

###############################################################################
#                                   vi mode                                   #
###############################################################################

bindkey -v
# export KEYTIMEOUT=1 # why?

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}

zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q' # Use beam shape cursor on startup.
precmd() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

###############################################################################
#                                   Utility                                   #
###############################################################################

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

bindkey -s '^o' '^ulfcd\n'
bindkey -s '^a' '^ubc -lq\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
bindkey '^[[P' delete-char

###############################################################################
#                              Last things to do                              #
###############################################################################

BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
