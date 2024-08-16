#!/usr/bin/env zsh

# soystemd --user
alias sc="systemctl"
alias scu="sc --user"
alias scue="scu enable"
alias scud="scu disable"
alias scus="scu start"
alias scuk="scu kill -s SIGKILL"
# there is also 'reload' but it aint applicable to all services
alias scur="scu daemon-reload && systemctl --user restart"
alias scuS="scu status"

# --- list commands ---
#   lookup 'sc list-*'. But most of the times 'list-*' command can be omitted in
#   favour of '--type' and '--state' flags
alias sculservices="sc --user --type=service --state=running"
alias scultargets="sc --user --type=target"
alias scultimers="sc --user --type=timer"
alias sculfailed="sc --user --failed"

# --- soystemd sudo ---
alias ssc="sudo systemctl"
alias ssce="ssc enable"
alias sscd="ssc disable"
alias sscs="ssc start"
alias ssck="scu kill -s SIGKILL"
alias sscr="ssc daemon-reload && systemctl restart"
alias sscS="ssc status"

# --- list commands ---
#   lookup 'sc list-*'. But most of the times 'list-*' command can be omitted in
#   favour of '--type' and '--state' flags
alias sclservices="sc --type=service --state=running"
alias scltargets="sc --type=target"
alias scltimers="sc --type=timer"
alias sclfailed="sc --failed"
