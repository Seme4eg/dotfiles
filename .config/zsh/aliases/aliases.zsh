#!/usr/bin/env zsh

alias cat="bat"
# du -h --max-depth=1 ~/ | sort -h # make an alias?
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)
alias jq="gojq"

alias vedroid="waydroid session stop && waydroid session start &"
alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file

alias gau="git update-index --assume-unchanged"
alias gnau="git update-index --no-assume-unchanged"
