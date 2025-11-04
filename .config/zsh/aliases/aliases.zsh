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

alias rsync_archive='sudo rsync -rP --delete ~/mem-arch/' # .. and append destination

ytdcur() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --output "${HOME}/Music/__dw/%(title)s.%(ext)s" "${url}"
}
