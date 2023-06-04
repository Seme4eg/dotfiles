#!/usr/bin/env zsh

# -a     only perform operation on AUR packages.
# -n     skip viewing PKGBUILD files when installing from the AUR.
# -N     skip confirmation prompts, also passed to pacman and makepkg.
# baph -c   - get an update count for both AUR and pacman packages.
# baph -uaN - update only the AUR packages and skip confirm dialogs

alias bi="baph -i"
alias bu="baph -u"
alias bs="baph -s"
alias bs="baph -s"
