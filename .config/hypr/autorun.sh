qutebrowser &
emacs &
syncthing &
# for mako
dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &
mako &
hyprpaper &
waybar &
pkexec /usr/bin/brillo -c 2
pkexec /usr/bin/brillo -I

# -i <img> -s fill
swayidle -w \
	timeout 300 'swaylock -f -e -k -l -c 000000' \
	timeout 600 'swaymsg "output * dpms off"' \
		resume 'swaymsg "output * dpms on"' \
	before-sleep 'swaylock -f -e -k -l -c 000000' &
