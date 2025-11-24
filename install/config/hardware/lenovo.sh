# lenovo setup

sudo pacman -S --noconfirm vulkan-intel lib32-vulkan-intel bolt
sudo ln $HOME/.config/tlp/02-lenovo.conf /etc/tlp.d/
sudo systemctl --now enable tlp.service
