###############################################################################
#                         Install 'grml-zsh-config' !                          #
###############################################################################

# stty stop undef # disable C-s to freeze terminal
# Nobody need flow control anymore. Troublesome feature.
#stty -ixon
setopt noflowcontrol
eval "$(zoxide init zsh)"

# --- Sourcing ---

# for now using powerlevel10k instead
# [ -f "~/.config/zsh/theming.zsh" ] && . "~/.config/zsh/theming.zsh"

# --- Variables ---
export BROWSER=qutebrowser
export EDITOR=vim

# --- Antidote (https://getantidote.github.io/) ---

[[ -e ~/.config/zsh/.antidote ]] || git clone https://github.com/mattmc3/antidote.git ~/.config/zsh/.antidote
. ~/.config/zsh/.antidote/antidote.zsh
antidote load ~/.config/zsh/plugins

# --- Aliases ---

alias pm="sudo pacman"
alias pmi="pm -S" # install
alias pmr="pm -Rs" # remove
alias pmsr="pm -Ss" # search remotes
alias pmsl="pm -Ss" # search locally
alias pmlo="pm -Qdt" # list orphaned
alias pmro="pm -Rns $(pacman -Qtdq)" # remove orphaned
alias pms="pm -Syy" # sync
alias pmU="pm -Syyu"
alias pmu="pm -Syu"
# -Scc is more agressive approach, read bout it before using in case u decide to
alias pmcc="pm -Sc" # Clear Cache

# yay -Yc # remove unneeded deps
# du -h --max-depth=1 ~/ | sort -h # make an alias?

alias grubmkc="sudo grub-mkconfig -o /boot/grub/grub.cfg"

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
