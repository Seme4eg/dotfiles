# lenovo setup

# sudo pacman -S --noconfirm vulkan-intel lib32-vulkan-intel bolt
# sudo ln --force $HOME/.config/tlp/02-lenovo.conf /etc/tlp.d/
# sudo systemctl --now enable tlp.service

# FIXME: overheating event likely caused the Embedded Controller (EC) to
# re-index the hardware registry so now tlp doesn't do the battery charging
# threshold. 'sudo tlp-stat -b' prints BAT1, but setting threshold for BAT1 in
# tlp config and 'sudo tlp start' errors out.
# So now need to do it manually:
sudo cat >"/etc/systemd/system/bat-conserv.service" <<EOF
[Unit]
Description=Enable Lenovo Battery Conservation Mode
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c 'echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'
ExecStop=/usr/bin/bash -c 'echo 0 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now bat-conserv.service
