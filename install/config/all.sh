source $DOTFILES_PATH/install/config/git-crypt.sh
source $DOTFILES_PATH/install/config/config.sh

# system settings overrides
source $DOTFILES_PATH/install/config/journal-mem-limit.sh
source $DOTFILES_PATH/install/config/lid-close-ignore.sh
source $DOTFILES_PATH/install/config/swappiness.sh

# systemd services
source $DOTFILES_PATH/install/config/system-services.sh
source $DOTFILES_PATH/install/config/user-services.sh
source $DOTFILES_PATH/install/config/fast-shutdown.sh
source $DOTFILES_PATH/install/config/increase-sudo-tries.sh
source $DOTFILES_PATH/install/config/ssh-flakiness.sh

# apps
source $DOTFILES_PATH/install/config/emacs.sh
source $DOTFILES_PATH/install/config/ags.sh
source $DOTFILES_PATH/install/config/go.sh
source $DOTFILES_PATH/install/config/earlyoom.sh
source $DOTFILES_PATH/install/config/steam.sh

# other stuff
source $DOTFILES_PATH/install/config/pam-gnupg.sh
source $DOTFILES_PATH/install/config/pnpm.sh
source $DOTFILES_PATH/install/config/theme.sh
source $DOTFILES_PATH/install/config/dash.sh

# hardware
source $DOTFILES_PATH/install/config/hardware/bluetooth.sh
source $DOTFILES_PATH/install/config/hardware/network.sh
source $DOTFILES_PATH/install/config/hardware/ignore-power-key.sh
source $DOTFILES_PATH/install/config/hardware/usb-autosuspend.sh

source $DOTFILES_PATH/install/config/hardware/lenovo.sh
source $DOTFILES_PATH/install/config/hardware/amd.sh
