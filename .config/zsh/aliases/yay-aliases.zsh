#!/usr/bin/env zsh

alias yi="yay -S"   # install
alias yr="yay -Rs"  # remove
alias ysr="yay -Ss" # search remotes
alias ysl="yay -Qs" # search locally
alias ys="yay -Syy" # sync
# -Scc is more agressive approach, read bout it before using in case u decide to
alias ycc="yay -Sc" # Clear Cache
# force a refresh of the package cache used for completions if it broke after
# above command
alias yfc="yay -Pcc" # yay fix cache
