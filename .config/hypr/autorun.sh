# for mako notifications if not on systemd
# dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &
# mako &

dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
systemctl --user start hyprland-session.target

/usr/lib/polkit-kde-authentication-agent-1 &
# /usr/libexec/xdg-desktop-portal-hyprland & # ain't needed with soystemd

firefox &
webcord --enable-features=UseOzonePlatform --ozone-platform=wayland &
emacs &

# nm-applet --indicator & # TODO: remove it when ya'll setup own wireless widget

pkexec /usr/bin/brillo -c 2
pkexec /usr/bin/brillo -I
