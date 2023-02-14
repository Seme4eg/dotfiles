/usr/lib/polkit-kde-authentication-agent-1 &
dbus-update-activation-environment --systemd \
  HOME DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

systemctl --user start hyprland-session.target

# /usr/libexec/xdg-desktop-portal-hyprland & # ain't needed with soystemd

gsettings set org.gnome.desktop.interface cursor-theme Future-dark-cursors
hyprctl setcursor Future-dark-cursors 26

wl-paste --watch cliphist store &

firefox &
webcord --enable-features=UseOzonePlatform --ozone-platform=wayland &
emacs &

pkexec /usr/bin/brillo -c 2
pkexec /usr/bin/brillo -I
