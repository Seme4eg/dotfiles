#!/usr/bin/env zsh

# --- Utilities ---
alias cat="bat"
# alternatives to rip:
# - https://github.com/andreafrancia/trash-cli
# - https://github.com/PhrozenByte/rmtrash
alias rm="rip -i" # https://github.com/nivekuil/rip
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)

# du -h --max-depth=1 ~/ | sort -h # make an alias?

alias vedroid="waydroid session stop && waydroid session start &"
alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file
