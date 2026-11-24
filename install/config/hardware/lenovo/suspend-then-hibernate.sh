# Lenovo firmware offers only s2idle (no S3) and drains ~1.2 W on long sleeps,
# so suspend-then-hibernate moves state to disk after HibernateDelaySec.
# https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation
# No resume= kernel param needed: on UEFI systemd-sleep stores the swap location
# in the HibernateLocation EFI variable and the systemd initramfs hook reads it.

# swap file sized to RAM so the image always fits
if [ ! -f /swapfile ]; then
  ram_gib=$(awk '/^MemTotal:/ {print int(($2 + 1048575) / 1048576)}' /proc/meminfo)
  sudo mkswap -U clear --size "${ram_gib}G" --file /swapfile
fi
grep -q '^/swapfile[[:space:]]' /etc/fstab ||
  echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab >/dev/null
grep -q '^/swapfile[[:space:]]' /proc/swaps || sudo swapon /swapfile

# fixed delay: default estimate keeps suspending until battery hits 5%
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/hibernate.conf >/dev/null <<'EOF'
[Sleep]
HibernateDelaySec=1h
EOF
