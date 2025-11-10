#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Dotfiles locations
export DOTFILES_PATH="$HOME/dotfiles"
export DOTFILES_INSTALL="$DOTFILES_PATH/install"
# TODO:
# export DOTFILES_INSTALL_LOG_FILE="/var/log/dotfiles-install.log"
export PATH="$DOTFILES_PATH/.local/bin:$PATH"

# Install
# source "$OMARCHY_INSTALL/helpers/all.sh"
source "$DOTFILES_INSTALL/pre-install/all.sh"
source "$DOTFILES_INSTALL/packaging/all.sh"
source "$DOTFILES_INSTALL/config/all.sh"
# source "$OMARCHY_INSTALL/login/all.sh"

# Allow passwordless reboot for the installer - removed on first-run
sudo tee /etc/sudoers.d/99-dotfiles-installer-reboot >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD: /usr/bin/reboot
EOF
sudo chmod 440 /etc/sudoers.d/99-dotfiles-installer-reboot

sudo reboot 2>/dev/null
