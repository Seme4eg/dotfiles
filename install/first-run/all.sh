#!/usr/bin/sh

set -e

FIRST_RUN_MODE=~/.local/state/first-run.mode

if [ -f "$FIRST_RUN_MODE" ]; then
  rm -f "$FIRST_RUN_MODE"

  bash $DOTFILES_PATH/install/first-run/cleanhome.sh
  bash $DOTFILES_PATH/install/first-run/mpd.sh
  bash $DOTFILES_PATH/install/first-run/mpv.sh
  bash $DOTFILES_PATH/install/first-run/cleanup-reboot-sudoers.sh
  bash $DOTFILES_PATH/install/first-run/firewall.sh

  # XXX:
  # bash "$OMARCHY_PATH/install/first-run/dns-resolver.sh"

  sudo rm -f /etc/sudoers.d/first-run
fi
