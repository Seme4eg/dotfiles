#!/usr/bin/env zsh

alias pm="sudo pacman"
alias pmi="pm -S" # install
alias pmr="pm -Rs" # remove
alias pmsr="pm -Ss" # search remotes
alias pmsl="pm -Qs" # search locally
alias pmlo="pm -Qdt" # list orphaned
# If no orphans were found, the output is error: argument '-' specified with
# empty stdin. This is expected as no arguments were passed to pacman -Rns.
alias pmro="pacman -Qtdq | sudo pacman -Rns -" # remove orphaned
alias pms="pm -Syy" # sync
alias pmU="pm -Syyu"
alias pmu="pm -Syu"
# -Scc is more agressive approach, read bout it before using in case u decide to
alias pmcc="pm -Sc" # Clear Cache
