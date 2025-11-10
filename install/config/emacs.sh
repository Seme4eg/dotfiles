# install & sync doom emacs

# TODO: 'if dir is empty / doesn't exist..'
git clone git@github.com:Seme4eg/.doom.d.git $HOME/.config/doom
cd $HOME/.config/doom
git-crypt unlock
git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs $HOME/.config/emacs
$HOME/.config/emacs/bin/doom install
$HOME/.config/emacs/bin/doom sync
rm -rf $HOME/.emacs.d
