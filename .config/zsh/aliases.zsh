#!/usr/bin/env zsh

# --- Pacman ---
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

# --- Yay ---
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

# du -h --max-depth=1 ~/ | sort -h # make an alias?

alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file
# XXX: remove it and make system to automount
# alias mount="sudo mount -t ntfs3" # /dev/sda1 ~/media/usb
alias check1="sudo lshw -C display"
alias check2="lspci -vnnn | perl -lne 'print if /^\d+\:.+(\[\S+\:\S+\])/' | grep VGA"

# soystemd --user
alias sc="systemctl"
alias scue="sc --user enable"
alias scus="sc --user start"
# there is also 'reload' but it aint applicable to all services
alias scur="sc --user restart"
alias scudr="sc --user daemon-reload"
alias scuS="sc --user status"
function reloadUUnit() { scudr && scur $1 && scuS $1 }

alias scl="sc list-units"
alias sclt="scl --type=target"
alias scf="sc --failed"

# --- soystemd sudo ---
alias ssc="sudo systemctl"
alias ssce="ssc enable"
alias sscr="ssc restart"
alias sscd="ssc disable"
alias sscs="ssc start"
alias sscS="ssc status"
