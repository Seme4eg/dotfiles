# source: omarchy repo

# Allow nothing in, everything out
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow ports for LocalSend
# sudo ufw allow 53317/udp
# sudo ufw allow 53317/tcp

# Turn on the firewall
sudo ufw --force enable

# Enable UFW systemd service to start on boot
sudo systemctl enable ufw

sudo ufw reload
