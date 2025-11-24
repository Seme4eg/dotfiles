export YAYDIR=$HOME/.cache/yay
if [ -d "$YAYDIR" ]; then
  rm -rf $YAYDIR
fi

mkdir -p $YAYDIR
git clone https://aur.archlinux.org/yay.git $YAYDIR
sudo pacman -Syy
cd $YAYDIR && makepkg -si --noconfirm
yay --version
