# Install all AUR packages

export MAKEFLAGS="-j$(nproc)"
yay -S --noconfirm - <$HOME/.local/share/pkgsaur
