# prevent steam to create yet another file in my home dir
echo 'cookie-file = ~/.config/pulse/cookie' |
  sudo tee -a /etc/pulse/client.conf >/dev/null
