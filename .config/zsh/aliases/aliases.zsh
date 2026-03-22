#!/usr/bin/env zsh

alias cat="bat"
alias vim="nvim"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"

alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' https://0x0.st" # < file or use < <(commmand) like wl-paste

alias gpgconf="sudo gpgconf --list-options gpg-agent"  # list all config options
alias gpgreload="echo RELOADAGENT | gpg-connect-agent" # forget all cached passwords

alias randstr="openssl rand -hex" # and pass length

alias chromium-it="chromium --proxy-server=socks://localhost:20170"
alias chromium-ru="chromium --proxy-server=socks://100.95.49.75:9080"

alias cheatengine="xhost +local: &; gameconqueror"

# mount torrent folder on homelab
alias mttorrent="sudo mount -t nfs -o vers=4 192.168.1.81:/home/earthian/data/torrents $XDG_DATA_HOME/torrents"

# bind = SUPERCTRL, W, exec, pkill ydotool || ydotoold & { sleep 0.4; ydotool click -r 3000 0xC0; }
# alias clicker="ydotoold &; sleep 0.4; ydotool mousemove --absolute 300 250; ydotool click -r 3000 0xC0"
# clicker() { ydotoold &; sleep 0.4; ydotool click -r 3000 0xC0; }

alias homediff="diff <(tree -L 1 -a --dirsfirst) dotfiles/.local/share/HOME"

# File system
if command -v eza &>/dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

if command -v zoxide &>/dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
