# for hyprland to not show error of undefined color var on first launch
wal -n -q -i "$DOTFILES_PATH/assets/wallpaper.jpg" --saturate 0.3

# gtk theme
THEME=$(shell gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
ICONS=$(shell gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
wpg-install.sh -G
# apply theme
nwg-look -a

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
