# Limine boot loader (UEFI, ESP mounted at /boot)
# https://wiki.archlinux.org/title/Limine
# Idempotent: on a fresh install the chroot steps from docs/arch.org are already
# done and only the pacman hook gets added.

esp=/boot
dir=$esp/EFI/arch-limine

sudo pacman -S --needed --noconfirm limine efibootmgr

sudo mkdir -p $dir
sudo cp /usr/share/limine/BOOTX64.EFI $dir/

if [[ ! -f $dir/limine.conf ]]; then
  # current kernel params without the ones GRUB injects
  cmdline=$(sed -E 's/(^| )(BOOT_IMAGE|initrd)=[^ ]*//g; s/^ +//' /proc/cmdline)
  cat <<EOF | sudo tee $dir/limine.conf
timeout: 3

/Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: $cmdline
    module_path: boot():/initramfs-linux.img
EOF
fi

if ! efibootmgr | grep -q 'arch-limine'; then
  part=$(findmnt -no SOURCE $esp)
  sudo efibootmgr --create \
    --disk /dev/$(lsblk -no PKNAME $part) \
    --part $(</sys/class/block/${part#/dev/}/partition) \
    --label "Arch Linux Limine Boot Loader" \
    --loader '\EFI\arch-limine\BOOTX64.EFI' \
    --unicode
fi

# redeploy the EFI binary on limine upgrades
sudo mkdir -p /etc/pacman.d/hooks
cat <<EOF | sudo tee /etc/pacman.d/hooks/99-limine.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = limine

[Action]
Description = Deploying Limine after upgrade...
When = PostTransaction
Exec = /usr/bin/cp /usr/share/limine/BOOTX64.EFI $dir/
EOF
