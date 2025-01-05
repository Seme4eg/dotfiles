#!/usr/bin/env zsh

alias fpi="flatpak install"                    # install without update syncing
alias fpinfo="flatpak info --show-permissions" # View sandbox permissions of application
alias fpr="flatpak uninstall"                  # remove
alias fpsr="flatpak search"                    # search remotes
alias fpsl="flatpak list | grep"               # search locally
# uninstall unused flatpak "refs" (aka orphans with no application/runtime)
alias fpro="flatpak uninstall --unused"
alias pmu="flatpak update" # update
