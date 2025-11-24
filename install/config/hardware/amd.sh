# install AMD specific software

# NOTE: do NOT install 'amdvlk & lib32-amdvlk', those are open-source drivers
# and will take precedence over proprietary ones if installed. Last time i
# bootstrapped the system those got somehow installed along something so do
# check and uninstall them if present. Proprietary drivers give like +10-15%
# more performance. To check which drivers are used: 'vulkaninfo --summary' ->
# driverID should be 'DRIVER_ID_MESA_RADV', not 'DRIVER_ID_AMD_OPEN_SOURCE'
# support for vulkan api
sudo pacman -S --noconfirm --needed --asdeps mesa mesa-utils lib32-mesa mesa-vdpau \
  libva-mesa-driver vulkan-radeon lib32-vulkan-radeon
yay -S --noconfirm amdgpu_top-bin
vulkaninfo --summary | grep -q OPEN_SOURCE && sudo pacman -Rns amdvlk lib32-amdvlk
