if sudo test -f /etc/sudoers.d/99-dotfiles-installer-reboot; then
  sudo rm -f /etc/sudoers.d/99-dotfiles-installer-reboot
fi
