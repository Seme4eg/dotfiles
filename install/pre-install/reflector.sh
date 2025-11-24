sudo pacman -Sy
sudo pacman -S --noconfirm reflector
sudo systemctl --now enable reflector.timer
