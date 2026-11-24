# install & sync doom emacs

DOOMDIR=$HOME/.config/doom
EMACSDIR=$HOME/.config/emacs

[ -d $DOOMDIR/.git ] || git clone git@github.com:Seme4eg/.doom.d.git $DOOMDIR
cd $DOOMDIR
[ -d .git/git-crypt/keys ] || git-crypt unlock

if [ ! -d $EMACSDIR/.git ]; then
  git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs $EMACSDIR
  $EMACSDIR/bin/doom install
fi
$EMACSDIR/bin/doom sync
rm -rf $HOME/.emacs.d
