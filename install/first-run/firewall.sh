# source: omarchy repo

# sudo ufw status verbose

# Allow nothing in, everything out
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow ports for LocalSend
# sudo ufw allow 53317/udp
# sudo ufw allow 53317/tcp

# --- OpenVPN ---
# do NOT set 'allow in' as it defeats the point of having firewall up
sudo ufw allow out on tun0
# sudo ufw allow out $port/$protocol # e.g. 1234/udp, depending on your OpenVPN client config
sudo ufw allow out 1194/udp
# Prefer resolved hosts to connect to your VPN, enable only if your VPN provider
# doesn't give you that option
# sudo ufw allow out 53

# Allow local IPv4 connections, enable as needed, set specific IPs or tighter subnet masks if possible
#ufw allow out to 10.0.0.0/8
#ufw allow out to 172.16.0.0/12
#ufw allow out to 192.168.0.0/16
# Allow IPv4 local multicasts
#ufw allow out to 224.0.0.0/24
#ufw allow out to 239.0.0.0/8
# Allow local IPv6 connections
#ufw allow out to fe80::/64
# Allow IPv6 link-local multicasts
#ufw allow out to ff01::/16
# Allow IPv6 site-local multicasts
#ufw allow out to ff02::/16
#ufw allow out to ff05::/16

# Turn on the firewall
sudo ufw --force enable

# Enable UFW systemd service to start on boot
sudo systemctl enable ufw

sudo ufw reload
