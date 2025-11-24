# fix dualsense controller connection:
# https://github.com/bluez/bluez/issues/673#issuecomment-2156084398
# https://github.com/ValveSoftware/SteamOS/issues/1710#issuecomment-2466422490
# NOTE: also first time connecting - use bluetoothctl and use PAIR command, not
# 'connect', it will prompt you for 'acceptance'. The only way. + don't forget
# to 'trust' it, otherwise on future connections you also will need to auth it
# via bluetoothctl.

sudo sed -i 's/^#\(UserspaceHID\)=.*/\1=true/' /etc/bluetooth/input.conf
sudo sed -i 's/^#\(ClassicBondedOnly\)=.*/\1=false/' /etc/bluetooth/input.conf
# for ags bluetooth service battery percentage
sudo sed -i 's/^#\(Experimental\) = .*/\1 = true/' /etc/bluetooth/main.conf

sudo systemctl enable --now bluetooth.service
