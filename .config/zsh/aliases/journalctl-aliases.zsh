#!/usr/bin/env zsh

# https://wiki.archlinux.org/title/Systemd/Journal
#
# flags:
# --grep=<pattern>
# -b -- messages from this boot (-b -1 shows msgs from perv. boot, etc..)
# -x -- Include explanations of log messages from the message catalog where available
# -f -- follow new messages
# -u -- messages by a specific (system) unit (man-db.service)
# --user -u -- messages from user services by a specific unit (dbus)

# journalctl /usr/lib/systemd/systemd # messages by a specific executable
# journalctl _PID=1 # messages by a specific process:
# journalctl -k # kernel ring buffer:

# journalctl -p err..alert # Show only error, critical and alert priority messages
# You can use numeric log level too, like journalctl -p 3..1. If single
# number/log level is used, journalctl -p 3, then all higher priority log levels
# are also included (i.e. 0 to 3 in this case).

alias jc="journalctl" 
alias jclb="jc --list-boots" # list of boots with their numbers
alias jclc="jc --list-catalogs"
alias jcst="jc --since" # .. "20 min ago"

