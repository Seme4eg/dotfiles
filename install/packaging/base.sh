# Install all pacman packages

sudo pacman -Syy
sudo pacman -S --noconfirm - <$HOME/.local/share/pkgspacman

tldr --update

# change shell to zsh, we need those env vars
# TODO: on next install - see which vars explicitly you need for installation
chsh -s /usr/bin/zsh
