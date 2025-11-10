# https://wiki.archlinux.org/title/Swap#Swappiness
echo 'vm.swappiness = 10' | sudo tee /etc/sysctl.d/99-sysctl.conf >/dev/null
