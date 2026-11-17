# prevent steam to create yet another file in my home dir
echo "[keyfile]
unmanaged-devices=interface-name:tailscale0" |
  sudo tee /etc/NetworkManager/conf.d/99-tailscale.conf >/dev/null

# tailscale netfilter rules break mullvad split-tunnel (excluded apps hang)
sudo tailscale set --netfilter-mode=off
