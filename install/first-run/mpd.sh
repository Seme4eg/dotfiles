mkdir -p $(XDG_DATA_HOME)/mpd
systemctl --user restart mpd.service
systemctl --user --now enable mpd.service
