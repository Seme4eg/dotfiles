# earlyoom -h
# without this change notifications won't work
# https://github.com/rfjakob/earlyoom/issues/270#issuecomment-1155020972
sudo sed -i 's/^\(DynamicUser=true\)/# \1/' \
  /usr/lib/systemd/system/earlyoom.service

echo EARLYOOM_ARGS=-m 5 -r 3600 -n \
  --avoid '(^|/)(init|systemd|Hyprland|sshd)$$' \
  --prefer '(^|/)(emacs|brave|steam|vesktop)$$' |
  sudo tee /etc/default/earlyoom >/dev/null

sudo systemctl --now enable earlyoom.service
