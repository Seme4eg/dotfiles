git clone git@github.com:vinceliuice/Elegant-grub2-themes.git \
  $HOME/.local/share/utils/$@
cd $HOME/.local/share/utils/grubtheme
# commit before borked opensuse pngs naming..
git reset --hard 6cfd864
sudo ./install.sh -s 2k -b
