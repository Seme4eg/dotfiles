. $ZDOTDIR/config.zsh

# Install & source grml-zsh-config
# --> https://grml.org/zsh/grml-zsh-refcard.pdf
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

zvm_vi_yank() {
  zvm_yank
  echo ${CUTBUFFER} | wl-copy
  zvm_exit_visual_mode
}

###############################################################################
#                                   Utility                                   #
###############################################################################

# NOTE: to get keys for defining binding: /usr/bin/cat -v , sir

bindkey '^p' history-substring-search-up
bindkey '^n' history-substring-search-down

fcd() { cd "$(find -type d | fzf)"; }
# ^o doesn't work in foot, cuz idk. In foot use ^O
bindkey -s '^o' 'fcd^M' # ^u in the beginning?

export ZSH_AUTOSUGGEST_STRATEGY=(completion history)
export ZSH_AUTOSUGGEST_HIGLIGHT_STYLE="fg=5"
bindkey '^ ' autosuggest-accept

bindkey '^_' fzf-history-widget

# --- fzf-tab ---
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-j:down' 'ctrl-k:up'

eval "$(zoxide init zsh)" # z / zi[nteractive] (using fzf if u have it)

# --- Sourcing ---
for file in ~/.config/zsh/aliases/*; do source "$file"; done

# i have cat aliased to 'bat' so i need to call cat directly
(/usr/bin/cat ~/.cache/wal/sequences &) # pywal

# For Fooocus
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh
