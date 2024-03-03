/usr/lib/polkit-kde-authentication-agent-1 &
dbus-update-activation-environment --systemd \
  DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

systemctl --user start hyprland-session.target

# /usr/libexec/xdg-desktop-portal-hyprland & # ain't needed with soystemd

# needs to be started before 'change-theme' script otherwise the latter waits
# for swaync service to appear
swaync &

swww init

change-theme &
# force update everything on every hyprland launch
sync_tz_and_loc -f &

wl-paste --watch cliphist store &

doom env
foot --server

(sleep 10 && mbsync mailru) &

pkexec /usr/bin/brillo -c 2
pkexec /usr/bin/brillo -I
