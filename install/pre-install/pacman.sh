# on init install remove hooks setting otherwise if pacman fails its gonna
# owerwrite the files, which is inconvenient. After successful bootstrap i see
# that change anyway and remove it.
sed -i '/HookDir/d' $DOTFILES_PATH/dotfiles/.config/pacman/pacman.conf

# add user config to main pacman conf
sudo sed -i '/^Architecture/ a\Include = $HOME/.config/pacman/pacman.conf' \
  /etc/pacman.conf

# add multilib repos
echo '
	[multilib]
	Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf

# refresh all repos
sudo pacman -Syu --noconfirm
