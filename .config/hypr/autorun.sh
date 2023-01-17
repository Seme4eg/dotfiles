# for mako notifications
dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &
mako &
/usr/lib/polkit-kde-authentication-agent-1 &
/usr/libexec/xdg-desktop-portal-hyprland &
# sleep 2
# /usr/lib/xdg-desktop-portal &

firefox &
webcord --enable-features=UseOzonePlatform --ozone-platform=wayland &
emacs &
syncthing & # XXX setup syncthing tray & syncthing service on startup maybe?

hyprpaper &
waybar &
nm-applet --indicator &
brillo -c 2
brillo -I
wlsunset -l 55.7 -L 37.6 -t 3000 &
