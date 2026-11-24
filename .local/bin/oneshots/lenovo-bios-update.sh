# Lenovo BIOS update from the Windows .exe package, without Windows.
#
# The .exe is a 7-Zip SFX (Insyde H2OFFT-W) holding a Lenovo-signed <MODEL><NN>WW.fd image.
# fwupd wraps the .fd in a UEFI capsule header, stages it on the ESP (capsule-on-disk);
# firmware verifies the signature and flashes on reboot. fwupd enforces AC power.
#
# Usage: source ~/bios/lenovo-bios-update.sh; lenovo-bios-update ~/Downloads/mtcn56ww.exe
lenovo-bios-update() {
	local exe=$1 tmp fd new cur dev
	if [ ! -f "$exe" ]; then
		echo "usage: lenovo-bios-update <bios-update.exe>" >&2
		return 1
	fi

	tmp=$(mktemp -d) || return 1
	if ! bsdtar -xf "$exe" -C "$tmp" '*.fd'; then
		echo "no .fd image found in $exe" >&2
		rm -rf "$tmp"
		return 1
	fi
	fd=$(find "$tmp" -type f -name '*.fd')
	if [ "$(printf '%s\n' "$fd" | wc -l)" -ne 1 ]; then
		echo "expected exactly one .fd in $exe, got:" >&2
		printf '%s\n' "$fd" >&2
		rm -rf "$tmp"
		return 1
	fi

	# Lenovo BIOS versions look like MTCN56WW: 4-char model prefix, 2-digit build, WW.
	new=$(basename "$fd" .fd | tr '[:lower:]' '[:upper:]')
	cur=$(cat /sys/class/dmi/id/bios_version)
	if [ "${new%????}" != "${cur%????}" ]; then
		echo "image $new is not for this machine (current BIOS $cur)" >&2
		rm -rf "$tmp"
		return 1
	fi
	if [ "${new:4:2}" -le "${cur:4:2}" ]; then
		echo "image $new is not newer than current BIOS $cur" >&2
		rm -rf "$tmp"
		return 1
	fi

	dev=$(fwupdmgr get-devices --json 2>/dev/null | jq -r '.Devices[]
		| select(.Plugin == "uefi_capsule" and .Name == "System Firmware" and (.Flags | index("updatable")))
		| .DeviceId')
	if [ -z "$dev" ] || [ "$(printf '%s\n' "$dev" | wc -l)" -ne 1 ]; then
		echo "could not find a single updatable 'System Firmware' device in fwupd" >&2
		rm -rf "$tmp"
		return 1
	fi

	echo "BIOS $cur -> $new via fwupd device $dev"
	sudo fwupdtool install-blob "$fd" "$dev"
	local rc=$?
	rm -rf "$tmp"
	return $rc
}
