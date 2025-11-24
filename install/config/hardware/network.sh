# install network manager captive portal dispatcher script
sudo wget --output-document \
  /etc/NetworkManager/dispatcher.d/90-open_captive_portal \
  'https://raw.githubusercontent.com/Seme4eg/captive-portal-sh/refs/heads/master/90-open_captive_portal'
sudo chmod +x /etc/NetworkManager/dispatcher.d/90-open_captive_portal
sudo systemctl daemon-reload && systemctl restart NetworkManager
