#!/usr/bin/env zsh

alias yi="yay -S"                          # install
alias yr="yay -Rs"                         # remove
alias ysr="yay -Sas"                       # search remotes
alias ysl="yay -Qs"                        # search locally
alias yfc="yay -Pcc"                       # yay fix cache
alias ys="yay -Syy && yay -Pcc >/dev/null" # sync and fix cache
alias yu="yay -Sayyu"                      # update only AUR packages
# -Scc is more agressive approach, read bout it before using in case u decide to
alias ycc="yay -Sc" # Clear Cache
# force a refresh of the package cache used for completions if it broke after
# above command
