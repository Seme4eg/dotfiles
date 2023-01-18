# for mako notifications if not on systemd
# dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &
# mako &

# FIXME: thing below fails, try to run it in terminal
# dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
systemctl --user start hyprland-session.target

/usr/lib/polkit-kde-authentication-agent-1 &
# /usr/libexec/xdg-desktop-portal-hyprland & # ain't needed with soystemd

firefox &
webcord --enable-features=UseOzonePlatform --ozone-platform=wayland &
emacs &

waybar &
nm-applet --indicator & # TODO: remove it when ya'll setup own wireless widget

pkexec /usr/bin/brillo -c 2
pkexec /usr/bin/brillo -I

wlsunset -l 55.7 -L 37.6 -t 3000 &

# TODO: setup waybars idle inhibitor or a shortcut to on/off it so the screen
# doesn't turn off when im watching something
# i <img> -s fill
# swayidle timeout 300 'swaylock -f -e -k -l -c 000000' timeout 600 'swaymsg "/usr/bin/hyprctl dispatch dpms off"' resume 'swaymsg "/usr/bin/hyprctl dispatch dpms on"' before-sleep '/usr/bin/swaylock -f -e -k -l -c 000000' &
