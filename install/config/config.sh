# create all needed dirs
mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/.local/share/fonts
mkdir -p $HOME/.local
mkdir -p $HOME/.ssh
# otherwise msmtp fails to create logfile
mkdir -p $HOME/.cache/msmtp
# https://github.com/lutris/docs/blob/master/WineDependencies.md#archendeavourosmanjaroother-arch-derivatives
mkdir -p $HOME/.local/share/wineprefixes

git submodule update --init --recursive

stow .

fc-cache
