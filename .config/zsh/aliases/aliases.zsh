#!/usr/bin/env zsh

alias cat="bat"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"
alias eh="cd ~/git/mp/web-arm/ && yarn serve"
alias pn="pnpm"

alias vedroid="waydroid session stop && waydroid session start &"
alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file
alias picgen="cd ~/utils/Fooocus && conda activate fooocus && \
  python entry_with_update.py --always-download-new-model"

# Paste image from clipboard, decode it with zbar and copy it back to clipboard
# https://github.com/tadfisher/pass-otp#examples - more examples
alias otpdecode="wl-paste | zbarimg -q --raw - | wl-copy"

alias gpgconf="sudo gpgconf --list-options gpg-agent" # list all config options
alias gpgreload="systemctl --user restart gpg-agent"

alias cheatengine="xhost +local: &; gameconqueror"

alias batinfo="upower -i /org/freedesktop/UPower/devices/battery_BATT"

# --grep=<pattern>
# -x -- Include explanations of log messages from the message catalog where available
# -u -- messages by a specific (system) unit (man-db.service)
# -e -- skip to the end
# --user -u -- messages from user services by a specific unit (dbus)
# -p err..alert # Show only error, critical and alert priority messages
#    You can use numeric log level too, like journalctl -p 3..1. If single
#    number/log level is used, journalctl -p 3, then all higher priority log
#    levels are also included (i.e. 0 to 3 in this case).

# journalctl /usr/lib/systemd/systemd # messages by a specific executable
# journalctl _PID=1 # messages by a specific process:
alias jc="journalctl --user -xe" # to see specific unit add -u flag
