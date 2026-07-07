# NOTE: NO - you can't just use 'HandleLidSwitchDocked' and not use custom
# hpyrland lid handler as you are closing the LID BEFORE your have 2nd monitor
# connected

sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/user.conf >/dev/null <<'EOF'
[Login]
HandlePowerKey=suspend
HandleLidSwitch=ignore
EOF
sudo systemctl restart systemd-logind

# shut back down if turned on with lid closed and single monitor
# happens a lot to me when laptop is in packed out backpack
sudo tee /usr/lib/systemd/system-sleep/relid-suspend >/dev/null <<'EOF'
#!/bin/sh
[ "$1" = post ] || exit 0
grep -qw closed /proc/acpi/button/lid/*/state 2>/dev/null || exit 0

n=$(cat /sys/class/drm/card*-*/status 2>/dev/null | grep -wc connected)
[ "$n" -gt 1 ] && exit 0 # docked (external present) → stay awake

# detached transient timer — independent of this hook's cgroup
systemd-run --on-active=2 systemctl suspend
exit 0
EOF
sudo chmod +x /usr/lib/systemd/system-sleep/relid-suspend
