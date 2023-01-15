firefox &
webcord --enable-features=UseOzonePlatform --ozone-platform=wayland &
emacs &
syncthing & # XXX setup syncthing tray & syncthing service on startup maybe?

# for mako notifications
dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &
#dbus-launch # XXX remove when telega is ok
mako &

hyprpaper &
waybar &
nm-applet --indicator &
brillo -c 2
brillo -I
wlsunset -l 55.7 -L 37.6 -t 3000 &
/usr/lib/polkit-kde-authentication-agent-1 &
/usr/libexec/xdg-desktop-portal-hyprland &
# sleep 2
# /usr/lib/xdg-desktop-portal &

# TODO: doesn't seem to work
# i <img> -s fill
swayidle -w \
	timeout 600 'swaymsg "output * dpms off"' \
		resume 'swaymsg "output * dpms on"' &
