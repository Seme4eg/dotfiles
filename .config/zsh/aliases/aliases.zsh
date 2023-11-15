#!/usr/bin/env zsh

alias cat="bat"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"
alias eh="cd ~/git/web-arm/ && yarn serve"

alias vedroid="waydroid session stop && waydroid session start &"
alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file

alias gau="git update-index --assume-unchanged"
alias gnau="git update-index --no-assume-unchanged"

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
alias jc="journalctl --user -xeu"
