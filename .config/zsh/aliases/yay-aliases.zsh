#!/usr/bin/env zsh

alias yi="yay -S" # install
alias yr="yay -Rs" # remove
alias yrd="yay -Yc" # remove unneeded deps
alias ysr="yay -Ss" # search remotes
alias ysl="yay -Qs" # search locally
alias ylo="yay -Qdt" # list orphaned
# If no orphans were found, the output is error: argument '-' specified with
# empty stdin. This is expected as no arguments were passed to pacman -Rns.
alias yro="pacman -Qtdq | sudo pacman -Rns -" # remove orphaned
alias ys="yay -Syy" # sync
alias yU="yay -Syyu"
alias yu="yay -Syu"
# -Scc is more agressive approach, read bout it before using in case u decide to
alias ycc="yay -Sc" # Clear Cache
# force a refresh of the package cache used for completions if it broke after
# above command
alias yfc="yay -Pcc" # yay fix cache
