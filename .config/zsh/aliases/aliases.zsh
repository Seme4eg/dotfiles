#!/usr/bin/env zsh

alias cat="bat"
alias vim="nvim"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"
alias spd="speedtest"

alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file or use < <(commmand) like wl-paste

# Paste image from clipboard, decode it with zbar and copy it back to clipboard
# https://github.com/tadfisher/pass-otp#examples - more examples
alias otpdecode="wl-paste | zbarimg -q --raw - | wl-copy"

alias gpgconf="sudo gpgconf --list-options gpg-agent"  # list all config options
alias gpgreload="echo RELOADAGENT | gpg-connect-agent" # forget all cached passwords

alias cheatengine="xhost +local: &; gameconqueror"

# mount torrent folder on homelab
alias mttorrent="sudo mount -t nfs -o vers=4 192.168.1.81:/home/earthian/data/torrents $XDG_DATA_HOME/torrents"

# bind = SUPERCTRL, W, exec, pkill ydotool || ydotoold & { sleep 0.4; ydotool click -r 3000 0xC0; }
# alias clicker="ydotoold &; sleep 0.4; ydotool mousemove --absolute 300 250; ydotool click -r 3000 0xC0"
# clicker() { ydotoold &; sleep 0.4; ydotool click -r 3000 0xC0; }

alias homediff="diff <(tree -L 1 -a --dirsfirst) dotfiles/.local/share/HOME"

# If at home replace tailscale ip with this one: earthian@192.168.1.81:~/homelab
# - before '--archive' flag i had '--recursive --times'
# - if adding '--info=progress2' add ONLY this info flag as mixed with any other
#   ones it turns to be a mess
# - if just want to see more info add --verbove (increases verbocity by one) and
#   it is essentially the '--info=' flag with sane params for all the info you
#   need. Run `rsync --info=help' to see all flags and levels`
alias rsync_archive='rsync --archive --info=progress2 --exclude=.stversions --delete ~/mem-arch/ earthian@100.95.49.75:~/archive'
alias rsync_archive_dry='rsync --archive --itemize-changes --dry-run --exclude=.stversions --delete ~/mem-arch/ earthian@100.95.49.75:~/archive'

ytdcur() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" "${url}"
}

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
