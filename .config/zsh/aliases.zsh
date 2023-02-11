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
# force a refresh of the package cache used for completions if it broke after
# above command
alias yfc="yay -Pcc" # yay fix cache

# --- Utilities ---
alias cat="bat"
# alternatives to rip:
# - https://github.com/andreafrancia/trash-cli
# - https://github.com/PhrozenByte/rmtrash
alias rm="rip -i" # https://github.com/nivekuil/rip
alias cd="z" # zoxide
alias du="ncdu" # get to know your storage (https://github.com/rofl0r/ncdu)

# du -h --max-depth=1 ~/ | sort -h # make an alias?

alias startvm="cd ~/utils/terminal-app-vm && qemu-system-x86_64 -net nic -net user,smb=/home/earthian/git/terminal-app -cpu host -enable-kvm -m 4096 -smp 4 -drive file=terminal-vm.qcow2,format=qcow2"

alias grubconf="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias 0x0="curl -F 'file=@-' 0x0.st" # < file
# XXX: remove it and make system to automount
# alias mount="sudo mount -t ntfs3" # /dev/sda1 ~/media/usb
alias check1="sudo lshw -C display"
alias check2="lspci -vnnn | perl -lne 'print if /^\d+\:.+(\[\S+\:\S+\])/' | grep VGA"
alias nmtui="sudo nmtui" # zoxide

# soystemd --user
alias sc="systemctl"
alias scu="sc --user"
alias scue="scu enable"
alias scud="scu disable"
alias scus="scu start"
# there is also 'reload' but it aint applicable to all services
alias scur="scu restart"
alias scudr="scu daemon-reload"
alias scuS="scu status"
function reloadUUnit() { scudr && scur $1 && scuS $1 }

alias scl="sc list-units"
alias sclt="sc list-timers"
alias sclt="scl --type=target"
alias scf="sc --failed"

# --- soystemd sudo ---
alias ssc="sudo systemctl"
alias ssce="ssc enable"
alias sscd="ssc disable"
alias sscs="ssc start"
alias sscr="ssc restart"
alias sscS="ssc status"

# --- openvpn service aliases ---
alias vpns="ssc start openvpn-client@client.service"
alias vpnstop="ssc stop openvpn-client@client.service"
alias vpnr="ssc restart openvpn-client@client.service"
alias vpnen="ssc enable --now openvpn-client@client.service"
alias vpnd="ssc disable openvpn-client@client.service"
alias vpnS="ssc status openvpn-client@client.service"
