# enable and start all user systemd services

find $HOME/.config/systemd/user/ -type f -printf "%f\n" |
  xargs -I {} systemctl --user enable --now {}

systemctl --user enable --now syncthing.service
systemctl --user enable --now udiskie.service
systemctl --user enable --now mpd-mpris.service
systemctl --user enable --now update_lsps.timer
