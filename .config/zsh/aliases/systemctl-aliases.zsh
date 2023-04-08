#!/usr/bin/env zsh

# soystemd --user
alias sc="systemctl"
alias scu="sc --user"
alias scue="scu enable"
alias scud="scu disable"
alias scus="scu start"
# there is also 'reload' but it aint applicable to all services
alias scur="scu daemon-reload && systemctl --user restart"
alias scuS="scu status"

alias scl="sc list-units"
alias sclt="sc list-timers"
alias sclt="scl --type=target"
alias scf="sc --failed"

# --- soystemd sudo ---
alias ssc="sudo systemctl"
alias ssce="ssc enable"
alias sscd="ssc disable"
alias sscs="ssc start"
alias sscr="ssc daemon-reload && systemctl restart"
alias sscS="ssc status"
alias ssclt="systemctl list-units --type=target"
