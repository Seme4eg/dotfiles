#!/usr/bin/env zsh

alias pm="sudo pacman"
alias pmi="pm -Sy && pm -S" # install
alias pmI="pm -S"           # install without package syncing
alias pmr="pm -Rs"          # remove
alias pmsr="pm -Ss"         # search remotes
alias pmsl="pm -Qs"         # search locally
alias pml="pm -Ql"          # list package
# If no orphans were found, the output is error: argument '-' specified with
# empty stdin. This is expected as no arguments were passed to pacman -Rns.
alias pmro="pacman -Qtdq | sudo pacman -Rns -" # remove orphaned
alias pms="pm -Syy"                            # sync
alias pmu="pm -Syu"                            # update
alias pmU="pm -Su"                             # update without syncing packages
# -Scc is more agressive approach, read bout it before using in case u decide to
alias pmcc="pm -Sc" # Clear Cache
