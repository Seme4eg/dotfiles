# -*- mode: sh; sh-shell: zsh -*-

# NOTE: to get keys for defining binding: cat -v , sir

. $ZDOTDIR/config.zsh

# Install & source grml-zsh-config
if [[ ! -f $ZDOTDIR/.grmlrc ]]; then
  echo "Fetching grml"
  wget -O $ZDOTDIR/.grmlrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc
fi
. $ZDOTDIR/.grmlrc

###############################################################################
#                  Antidote (https://getantidote.github.io/)                  #
###############################################################################

# run 'antidote update' to update plugins

# NOTE ANTIDOTE_DIR is forward-declared in modules/home/shell-zsh.nix
[[ -e ~/.config/zsh/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git $ZDOTDIR/.antidote
. $ZDOTDIR/.antidote/antidote.zsh
antidote load $ZDOTDIR/plugins

###############################################################################
#                              End Antidote setup                             #
###############################################################################

###############################################################################
#                                   vi mode                                   #
###############################################################################

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# https://github.com/jeffreytse/zsh-vi-mode
# Always starting with insert mode for each command line
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT # <- gets defined only after zvm sourcing

###############################################################################
#                                   Utility                                   #
###############################################################################

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# https://github.com/gokcehan/lf/blob/master/etc/lfcd.sh
lfcd () {
  tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" -a "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}

# Use lf to switch directories and bind it to ctrl-o
bindkey -s '^o' '^ulfcd\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

ZSH_AUTOSUGGEST_STRATEGY=(completion history)
ZSH_AUTOSUGGEST_HIGLIGHT_STYLE="fg=5"
bindkey '^ ' autosuggest-accept

bindkey '^_' fzf-history-widget

###############################################################################
#                              Last things to do                              #
###############################################################################

eval $(thefuck --alias) # https://github.com/nvbn/thefuck

eval "$(zoxide init zsh)" # z / zi[nteractive] (using fzf if u have it)
stty stop undef # disable C-s to freeze terminal
# Nobody needs flow control anymore. Troublesome feature.
#stty -ixon
setopt noflowcontrol

# --- Sourcing ---
. ~/.config/zsh/aliases.zsh

# for now using powerlevel10k instead
# [ -f "~/.config/zsh/theming.zsh" ] && . "~/.config/zsh/theming.zsh"

# i have cat aliased to 'bat' so i need to call cat directly
( /usr/bin/cat ~/.cache/wal/sequences & ) # pywal

if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
  # init-nvm.sh contents with bash_completion excluded and nvm dir changed
  [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.config/nvm"
  source /usr/share/nvm/nvm.sh
  source /usr/share/nvm/install-nvm-exec
fi

# BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh
