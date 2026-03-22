# prevent steam to create yet another file in my home dir
echo "[keyfile]
unmanaged-devices=interface-name:tailscale0" |
  sudo tee -a /etc/NetworkManager/conf.d/99-tailscale.conf >/dev/null
