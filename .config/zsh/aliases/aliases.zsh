#!/usr/bin/env zsh

alias cat="bat"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"
alias eh="cd ~/git/mp/web-arm/ && yarn serve"
alias pn="pnpm"
alias spd="speedtest"

alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file
alias 0x0clip="wl-paste | curl -F 'file=@-' 0x0.st"
alias picgen="cd ~/utils/Fooocus && conda activate fooocus && \
  python entry_with_update.py --always-download-new-model"
alias nmssaveedit="cd Downloads/nms/jdk-22.0.2/bin && ./java -jar ~/Downloads/nms/NMSSaveEditor.jar"

# Paste image from clipboard, decode it with zbar and copy it back to clipboard
# https://github.com/tadfisher/pass-otp#examples - more examples
alias otpdecode="wl-paste | zbarimg -q --raw - | wl-copy"

alias gpgconf="sudo gpgconf --list-options gpg-agent" # list all config options
alias gpgreload="systemctl --user restart gpg-agent"

alias cheatengine="xhost +local: &; gameconqueror"

# NOTE: tlp-stat also shows the capacity
alias batinfo="upower -i /org/freedesktop/UPower/devices/battery_BATT"

ytdcur() { # yt-dlp download current
  url="$(wl-paste)"
  url="${url%?list*}"
  yt-dlp -x --output "${HOME}/Music/__dw/%(artist)s - %(title)s.%(ext)s" "${url}"
}
