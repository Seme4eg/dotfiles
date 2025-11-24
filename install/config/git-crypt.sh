# or otherwise unsave permissions
mkdir -p -m700 $HOME/.gnupg
sudo pacman -S --noconfirm git stow git-crypt
git-crypt unlock
