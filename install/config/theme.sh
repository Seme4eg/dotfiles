# grub theme
git clone git@github.com:vinceliuice/Elegant-grub2-themes.git \
  $HOME/.local/share/utils/$@
cd $HOME/.local/share/utils/grubtheme
# commit before borked opensuse pngs naming..
git reset --hard 6cfd864
sudo ./install.sh -s 2k -b

# for hyprland to not show error of undefined color var on first launch
wal -n -q -i "$DOTFILES_PATH/assets/wallpaper.jpg" --saturate 0.3

# gtk theme
THEME=$(shell gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
ICONS=$(shell gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
wpg-install.sh -G
# apply theme
nwg-look -a

# TODO: line to install flatpak packages from my pkgsflatpak file
# Fix for theming in flatpak applications:
# source: https://web.archive.org/web/20230106121332/https://itsfoss.com/flatpak-app-apply-theme/
sudo flatpak override --filesystem=$HOME/.local/share/themes
sudo flatpak override --filesystem=$HOME/.local/share/icons
sudo flatpak override --env=GTK_THEME=$THEME
sudo flatpak override --env=ICON_THEME=$ICONS

# setup cursor icons
CURSOR_DIR=$DOTFILES_PATH/.local/share/icons
CURSOR_NAME=BreezeX-RosePine-Linux.tar.xz
echo "Extracting $CURSOR_DIR/$CURSOR_NAME .."
tar -C $CURSOR_DIR -xf "$CURSOR_DIR/$CURSOR_NAME"
nwg-look -a
