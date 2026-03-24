sudo mkdir -p /etc/systemd/system.conf.d

cat <<EOF | sudo tee /etc/systemd/system.conf.d/10-faster-shutdown.conf
[Manager]
DefaultTimeoutStopSec=5s
EOF

sudo mkdir -p /etc/systemd/system/user@.service.d

cat <<EOF | sudo tee /etc/systemd/system/user@.service.d/faster-shutdown.conf
[Manager]
TimeoutStopSec=5s
EOF

sudo systemctl daemon-reload
