# Lenovo ThinkBook X IMH (21NW) — journalctl errors

Arch Linux. Part 1: baseline on BIOS MTCN48WW. Part 2: fix checklist after update to MTCN56WW and later boots.

## Journal error spam — baseline before BIOS update

Captured: 2026-11-20 ~00:45 (+07:00)
Machine: LENOVO 21NW ThinkBook X IMH
BIOS: MTCN48WW (10/16/2024) — update target MTCN56WW
Kernel: 7.2.3-arch1-2
Boot analysed: current boot, up since 2026-11-15 03:16:12

### 1. ACPI fan error — main spam, firmware bug (BIOS update may fix)

Exact lines (always as a pair):

    ACPI BIOS Error (bug): Could not resolve symbol [\_SB.FANL], AE_NOT_FOUND (20260408/psargs-365)
    ACPI Error: Aborting method \VFAN._FST due to previous error (AE_NOT_FOUND) (20260408/psparse-543)

- Rate: one pair every ~2.0 s, ~1800 pairs/hour, continuous.
- Count in journal for this boot: 25201 pairs.
- Source: ACPI fan device `\VFAN` (PNP0C0B:05). Its `_FST` (fan status) method references
  `\_SB.FANL`, which does not exist in the firmware's ACPI tables (DSDT/SSDT bug).
  Triggered whenever fan status is read (hwmon `acpi_fan`), polled every 2 s.

### 2. Kernel WARNING in v4l2_open — not BIOS related

Exact lines (each followed by a full call trace, ~60 lines):

    WARNING: drivers/media/v4l2-core/v4l2-dev.c:438 at v4l2_open+0xfc/0x150 [videodev], CPU#14: brave/2810902
    !test_bit(V4L2_FL_USES_V4L2_FH, &vdev->flags)

- Count this boot: 288 (first 2026-11-18 01:01, last 2026-11-20 00:39).
- Triggered when brave/chromium open video devices (camera enumeration).
- Likely cause: `/dev/video0` "Loopback video device" from out-of-tree module
  `v4l2loopback_dc` (DroidCam, taints kernel OE) not updated for kernel 7.2's
  v4l2_fh requirement. BIOS update will not change this.

### 3. Firewall log noise — not errors

- `[UFW BLOCK] IN=wlp... / IN=tailscale0 ...` — 4388 lines this boot, mostly
  blocked multicast UDP. Normal ufw logging.

### 4. Lower-volume errors (not spam, for comparison)

- amdgpu 0000:05:00.0: `device lost from bus!` (16), `MES failed to respond to msg=REMOVE_QUEUE` (27),
  `failed to unmap legacy queue` (27), `[gfxhub] page fault` (10, from chromium),
  `SMU: bus error for message: TransferTableSmu2Dram` (9). Seen 2026-11-18 and 2026-11-19.
- Bluetooth: `RAP unable to attach` / `rap profile accept failed` (10),
  `Unable to get Hands-Free Voice gateway SDP record: Host is down` (7).

### Re-check after BIOS update

    cat /sys/class/dmi/id/bios_version                                  # expect MTCN56WW
    journalctl -b -k -o cat | grep -cF '\_SB.FANL'                      # item 1: 0 = fixed
    journalctl -b -k -o short-monotonic | grep -F 'FANL' | tail -5      # item 1: rate if still present
    journalctl -b -k -o cat | grep -c 'v4l2-dev.c:438'                  # item 2
    journalctl -b -p warning -o cat | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -20   # overall

## Journal errors after BIOS update — fix checklist

Captured: 2026-11-20, boot 2026-11-20 01:01:11, counts at uptime 590 s
BIOS: MTCN56WW (09/21/2026), kernel 7.2.3-arch1-2
Source: `journalctl -b -p warning` (UFW BLOCK firewall logging excluded)
Rechecked: 2026-11-21, boot 2026-11-20 23:59:39 after full system update (kernel 7.3.5-arch1-1, systemd 262.2, bluez 5.88, wpa_supplicant 2:2.12-2), uptime ~3 min.
New items from that boot tagged **(new, 7.3.5)**; open items absent from it noted "not on 7.3.5 boot" (short uptime, may still appear).

### 1. Firmware / ACPI

- [x] **ACPI fan error — spam, every 2 s** (287 pairs in 590 s). Survived BIOS update. — fixed: ags `cpuTemp` poll (right_right.js:37) `sensors -j` → `sensors -j coretemp-isa-0000`; BIOS bug itself (`\VFAN._FST` → missing `\_SB.FANL`) remains, any other fan reader still triggers it. Verified 7.3.5 boot: 0.
      `ACPI BIOS Error (bug): Could not resolve symbol [\_SB.FANL], AE_NOT_FOUND (20260408/psargs-365)`
      `ACPI Error: Aborting method \VFAN._FST due to previous error (AE_NOT_FOUND) (20260408/psparse-543)`
      Device `\VFAN` = PNP0C0B:05 (hwmon `acpi_fan`); something reads its fan status every 2 s.
- [x] **ACPI charger error — once at boot (4.4 s)** — harmless, left as is: BIOS regression in MTCN56WW (absent on MTCN48WW). `int3403_thermal` probe of INTC1062:00 (`\_SB.IETM.CHRG`) evaluates `PPSS`, which reads nonexistent `H_EC.DPTF.FCHG` (SSDT18) → probe fails, no CHRG cooling device. Unused here (no thermald); EC handles charging.
      `ACPI BIOS Error (bug): Could not resolve symbol [\_SB.PC00.LPCB.HEC.DPTF.FCHG], AE_NOT_FOUND (20260408/psargs-365)`
      `ACPI Error: Aborting method \_SB.IETM.CHRG.PPSS due to previous error (AE_NOT_FOUND) (20260408/psparse-543)`
- [x] **EFI partition dirty flag** — fixed with `fsck.vfat -a /dev/nvme0n1p1`
      `FAT-fs (nvme0n1p1): Volume was not properly unmounted. Some data may be corrupt. Please run fsck.`
      Verify next boot: `journalctl -b -k | grep -F 'FAT-fs (nvme0n1p1)'` prints nothing. Verified 7.3.5 boot: nothing.

### 2. Kernel drivers

- [x] **v4l2 WARNING with call trace** (14: brave 11, v4l_id 2, wireplumber 1) — fixed: kernel ≥6.18 rejects opens on drivers without `v4l2_fh` (DroidCam fork `v4l2loopback-dc-dkms` 2.1.4). Removed it, upstream `v4l2loopback-dkms` 0.15.4 loaded via `/etc/modprobe.d/v4l2loopback.conf` (`alias v4l2loopback_dc v4l2loopback`, `video_nr=0 exclusive_caps=1 card_label=DroidCam`), so droidcam's own `modules-load.d/droidcam.conf` keeps working. Live test: 1920x1080 stream through `/dev/video0`, no WARNING. Verify next boot: `journalctl -b -k | grep -c v4l2-dev.c:438` = 0. Verified 7.3.5 boot: 0, `systemd-modules-load` ok, `/dev/video0` = DroidCam. Separate: `droidcam` binaries need AUR rebuild (`libswscale.so.9` missing since ffmpeg 9).
      `WARNING: drivers/media/v4l2-core/v4l2-dev.c:438 at v4l2_open+0xfc/0x150 [videodev]`
      `!test_bit(V4L2_FL_USES_V4L2_FH, &vdev->flags)`
      Likely `/dev/video0` "Loopback video device" from out-of-tree `v4l2loopback_dc` (DroidCam):
      `v4l2loopback_dc: loading out-of-tree module taints kernel.`
      Related: wireplumber `spa.v4l2: Cannot open '/dev/video0': 19, No such device`
- [x] **Wi-Fi regulatory database missing** — harmless, left as is: `wireless-regdb` not installed; AX211 is self-managed (firmware regdom VN), ignores global `00`. Fix if ever needed: `pacman -S wireless-regdb`.
      `faux_driver regulatory: Direct firmware load for regulatory.db failed with error -2`
- [x] **Thunderbolt 3 dock USB controller dies during boot** **(new, 7.3.5)** — JHL7440 Titan Ridge (`boltctl`: "Tapex Creek", authorized). Firmware-created tunnel at 0.8 s; `thunderbolt` driver loads 2.79 s, xhci dies 2.89 s, dock re-found 3.96 s, xhci back 7.58 s. Dock was attached on 7.2.3 boot too, no error there. — fix applied, verify next boot: `options thunderbolt host_reset=0` in `/etc/modprobe.d/thunderbolt.conf` via `~/dotfiles/install/config/hardware/thunderbolt.sh` (idempotent, sourced in `all.sh`). Cause: dock is eGPU box (Navi 33 `05:00.0` + xhci `06:00.0`); BIOS builds PCIe tunnel at power-on, `thunderbolt` loads after switch root (2.23 s) with default `host_reset=Y`, resets USB4 host router, tunnel dropped (pciehp Slot(13) Link Down 2.885 s), xhci dies, bridge windows not released; tunnel rebuilt 6.10 s, xhci back 7.58 s. Correction: on 7.2.3 boot the dock was hot-plugged at 5284 s, not attached at boot, so "new, 7.3.5" unproven. Verify (reboot with dock attached): `cat /sys/module/thunderbolt/parameters/host_reset` = N, `journalctl -b -k | grep -cE 'HC died|was not released'` = 0. Verified 2026-11-24 boot (dock attached): `host_reset` = N, `HC died` = 0, xhci `06:00.0` stays up. `was not released` = 2, but not from this: the 2 bridge-window lines below come from amdgpu's resizable-BAR attempt (21 ms after `amdgpu 0000:05:00.0: enabling device`, then `Not enough PCI address space for a large BAR.`), same on the pre-fix boot; see section 5. Boot -1 `HC died` at 4477 s = physical dock unplug (expected). **Reverted 2026-11-24 (user choice), left as is:** `thunderbolt.sh`, its `all.sh` line and `/etc/modprobe.d/thunderbolt.conf` removed (stale copy in initramfs inert, `thunderbolt.ko` not in it; gone on next rebuild). From next boot `HC died` at boot returns; xhci recovers ~5 s later.
      `xhci_hcd 0000:06:00.0: Controller not ready at resume -19`
      `xhci_hcd 0000:06:00.0: PCI post-resume error -19!`
      `xhci_hcd 0000:06:00.0: HC died; cleaning up`
      `xhci_hcd 0000:06:00.0: Host halt failed, -19`
      `xhci_hcd 0000:06:00.0: Host not accessible, reset failed.`
      `pcieport 0000:01:00.0: bridge window [mem 0x4010000000-0x48201fffff 64bit pref]: was not released (still contains assigned resources)`
      `pcieport 0000:00:07.0: bridge window [mem 0x4010000000-0x482fffffff 64bit pref]: was not released (still contains assigned resources)`
- [x] **IPU6 psys runtime PM on resume** (once per resume, every boot; found 2026-11-24, b-2 1, b-1 13, b0 1; right after `intel-ipu6 0000:00:05.0: IPU6 in secure mode`) — no local fix, left as is. 1:1 with `PM: suspend exit` on 7.2.3 and 7.3.5 (not BIOS/kernel-update related). Kernel `drivers/media/pci/intel/ipu6/ipu6.c` `ipu6_resume()` calls `pm_runtime_resume_and_get()` on the psys auxiliary device, which has no driver in mainline (only isys loads; `intel_ipu6.psys.40` has no `driver` link). Likely: psys has no system-sleep callbacks, stays runtime-suspended via direct_complete with runtime PM disabled until its own resume, which runs after the parent's, so the call fails. Effect: `ipu6_buttress_authenticate()` (secure mode) skipped on resume. No upstream change to this path as of 2026-11-24. Camera works after resume anyway: resume 18:04:00, libcamera stream with frames 18:17:00-18:17:03 (2026-11-24 boot).
      `auxiliary intel_ipu6.psys.40: Failed to get runtime PM`
      Recount form: `auxiliary intel_ipuN.psys.N: Failed to get runtime PM`

### 3. Desktop / userspace

- [x] **ags bar — media widget** (`~/.config/ags/js/left.js`) — fixed: null-safe `active?.`, `v?.length`
      `JS ERROR: TypeError: active is undefined` (27) — left.js:43 `Media/trackTitle`, :55 `Media/artist`, :78 `Media/revealArtist`
      `JS ERROR: TypeError: v is null` (4) — left.js:96 `Title/<.truncate`
      Separate, not ags (section 5, harmless), playerctld: `could not get properties for active player: GDBus.Error:org.freedesktop.DBus.Properties.Error.InterfaceNotFound`
- [x] **ags bar — widget property** — fixed: right_left.js:150 `hpack: "end"`
      agsv1: `Error: hpack has to be on of fill,start,end,center,baseline, but it is right` (2)
- [x] **NetworkManager ignores a connection file** — fixed: stale `0644` copy of cisco VPN (likely Emacs auto-save) moved to `/root/`
      `keyfile: load: "/etc/NetworkManager/system-connections/#476a2b0f4788b0ac5aa46c94781f0b45800c2d89#": failed to load connection: File permissions (100644) are insecure`
- [x] **systemd drop-in ignored** — fixed: `[Manager]` → `[Service]` in drop-in and `~/dotfiles/install/config/fast-shutdown.sh`; user@1000 TimeoutStopUSec=5s
      `/etc/systemd/system/user@.service.d/faster-shutdown.conf:1: Unknown section 'Manager'. Ignoring.`
- [x] **D-Bus activation of missing services** — Avahi fixed: mpd `zeroconf_enabled "no"` (requester was mpd). home1 (PAM `pam_systemd_home.so` at login) and resolve1 (tailscaled DNS-mode probe) harmless, left as is.
      `Activation request for 'org.freedesktop.Avahi' failed: The systemd unit 'dbus-org.freedesktop.Avahi.service' could not be found.`
      `Activation request for 'org.freedesktop.home1' failed: The systemd unit 'dbus-org.freedesktop.home1.service' could not be found.`
      `Activation request for 'org.freedesktop.resolve1' failed: The systemd unit 'dbus-org.freedesktop.resolve1.service' could not be found.`
- [x] **D-Bus service file naming** — harmless, left as is: cosmetic, dbus-broker still loads both (`org.freedesktop.Notifications`, `org.freedesktop.FileManager1` activatable). Logged once each at login, plus on every package change in `/usr/share/dbus-1/services`; swaync 0.12.6-2 / thunar 4.20.10-1.
      `Service file '/usr/share/dbus-1/services/org.erikreider.swaync.service' is not named after the D-Bus name 'org.freedesktop.Notifications'.`
      `Service file '/usr/share/dbus-1/services/org.xfce.Thunar.FileManager1.service' is not named after the D-Bus name 'org.freedesktop.FileManager1'.`
- [x] **UPower not available to wireplumber** — fixed: `systemctl enable upower` (`WantedBy=graphical.target`), upowerd up before login. Was login race: wireplumber's `libspa-bluez5.so` (`upower.c`, host battery level for HFP) queries with auto-start off; upowerd was only D-Bus-activated by ags `Service.import("battery")` (right_right.js:1). Boot -1: activation 01:01:28.229, query failed .826, upower ready .942. Transient: plugin re-queries on `NameOwnerChanged`. Not on 7.3.5 boot (race won). Verify next boot: `journalctl -b | grep -c 'percentage from UPower'` = 0, upower started before wireplumber. Verified 2026-11-24 boot: 0; upower 18:02:52.9, wireplumber 18:03:03.2.
      `default: Failed to get percentage from UPower: org.freedesktop.DBus.Error.NameHasNoOwner`
- [x] **gnome-keyring** — harmless, left as is: `gkr-pam` line is by design (PAM auth runs before daemon exists, password stashed, `unlocked login keyring` at session open). "already registered" = Chromium + Element (`electron43-flags.conf` `--password-store=gnome-libsecret`) rewriting dummy item `Chrome Safe Storage Control` at startup (crbug 660005); data unaffected.
      login: `gkr-pam: unable to locate daemon control file`
      `asked to register item /org/freedesktop/secrets/collection/login/4, but it's already registered` (2)
- [x] **hyprpolkitagent portal registration** — fixed by update (hyprpolkitagent 0.1.3-10 → 0.2.0-3 and/or qt6-base 6.11.2-3 → 6.12.0-5, which one unknown). Was Qt host-portal `Register` with empty app ID (no .desktop file), reply when D-Bus-activated portal came up (boot -1: agent 01:01:26.775, portal ready 01:01:28.168, error .169). Startup-only event; 7.3.5 boot passed it clean. Verify next login: `journalctl -b | grep -c 'Could not register app ID'` = 0. Verified 2026-11-24 boot: 0.
      `Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for ''")`
- [x] **syncthing starts before DNS is up** (3) — harmless, left as is: login race, user `syncthing.service` starts at login, relay listener fetches pool before Wi-Fi up (boot -1: syncthing 01:01:23.133, fail .387, NM `CONNECTED_GLOBAL` 01:01:25.463). Supervisor retries: peer connected 01:02:43, `Joined relay` 01:03:12. Recurs only if login beats Wi-Fi. Fix if ever needed: user drop-in `ExecStartPre=-/usr/bin/nm-online -q -t 30`. Separate: `could not find a connectable relay` later in session (01:33:45, 21:05:20), not investigated.
      `Service failed (error="Get \"https://relays.syncthing.net/endpoint\": dial tcp: lookup relays.syncthing.net: Temporary failure in name resolution" ...)`
- [x] **bluetoothd LE Audio (BAP)** — fixed: LE Audio enabled, `KernelExperimental = 6fbaf188-05e0-496a-9885-d6ddfdb4e03e` (ISO socket) in `/etc/bluetooth/main.conf` via `~/dotfiles/install/config/hardware/bluetooth.sh` (idempotent sed). Kernel `CONFIG_BT_LE=y`, AX211 `cis-central cis-peripheral`; probe was for Galaxy Buds4 Pro (8C:A3:EC:78:0D:43, PACS/ASCS). After `systemctl restart bluetooth`: Adapter1 `ExperimentalFeatures` has ISO UUID, pipewire `/MediaEndpointLE/BAPSink/lc3` + `BAPSource/lc3` registered, no BAP lines. Buds `Paired: no`: pair to use LE Audio. Verify next boot: `journalctl -b -t bluetoothd | grep -c 'ISO Socket'` = 0. Verified 2026-11-24 boot: 0.
      `profiles/audio/bap.c:bap_adapter_probe() BAP requires ISO Socket which is not enabled`
      `src/service.c:service_probe() bap profile probe failed for 8C:A3:EC:78:0D:43`
      `bap: Operation not supported (95)`
      `profiles/audio/bap.c:bap_probe() BAP requires ISO Socket which is not enabled` (7.3.5 boot)
- [x] **bluetooth.service config dir mode** **(new, 7.3.5)** — harmless, left as is: Arch bluez 5.88-1 packaging mismatch. Unit now `ConfigurationDirectoryMode=0755` (5.87-2 had `0555`), package still ships `/etc/bluetooth` mode 555. systemd only warns (no chmod), once per bluetooth.service start; bluetoothd only reads it. Wait for packaging fix. Not chmod (pacman mismatch), not drop-in (inverts if Arch ships 755).
      `bluetooth.service: ConfigurationDirectory 'bluetooth' already exists but the mode is different. (File system: 555 ConfigurationDirectoryMode: 755)`
- [x] **bluetoothd RFCOMM Hands-Free** **(new, 7.3.5)** — fixed: `hfp_hf` dropped from pipewire roles, `~/.config/wireplumber/wireplumber.conf.d/14-bluez-roles.conf` (`bluez5.roles` = default minus `hfp_hf`). Clash on RFCOMM channel 7: `Experimental = true` enables bluetoothd's experimental `profiles/audio/hfp-hf.c` (fixed `HFP_HF_DEFAULT_CHANNEL` 7), wireplumber's `RegisterProfile` for "Hands-Free unit" gets same default channel. Only laptop-as-handsfree-for-phone role affected (now BlueZ native only); `hfp_ag` (headsets) unchanged. Verified: `systemctl --user restart wireplumber`, no RFCOMM error. Verify next boot: `journalctl -b -t bluetoothd | grep -c 'RFCOMM server failed'` = 0. Verified 2026-11-24 boot: 0.
      `src/profile.c:ext_start_servers() RFCOMM server failed for Hands-Free unit: rfcomm_bind: Address already in use (98)`
- [x] **swaync** — Config line fixed: `"widget-config": { "notifications": {} }` in `~/.config/swaync/config.json` (was `{}` while `widgets` lists `notifications`; empty object = same defaults). Verified after `systemctl --user restart swaync`: 0. Dark-theme line fixed by update: libadwaita 1.9.3 → 1.10.0 no longer warns, `gtk-application-prefer-dark-theme=1` in `~/.config/gtk-4.0/settings.ini` unchanged; 7.3.5 boot: 0 from any process.
      `baseWidget.vala:47: notifications: Config not found! Using default config...` (2)
      `Using GtkSettings:gtk-application-prefer-dark-theme with libadwaita is unsupported. Please use AdwStyleManager:color-scheme instead.` (not on 7.3.5 boot)
- [x] **foot** — OSC line fixed: `~/.config/zsh/.zshrc:89` printed pywal `~/.cache/wal/sequences` incl. `ESC]4;256;…` (palette index foot lacks), once per interactive zsh in foot; now `sed` strips it. Verified: zsh in footclient 0 warnings, direct `4;256` control 1. xdg-toplevel-icon line harmless, left as is: Hyprland 0.57.2 lacks `xdg-toplevel-icon-v1`, once per foot-server start.
      `osc: invalid OSC 4 color index: 256` (not on 7.3.5 boot)
      `wayland: compositor does not implement the xdg-toplevel-icon protocol`
- [x] **NetworkManager P2P forwarding** — harmless, left as is: NM 1.58.1 per-device `ipv4.forwarding` write for Wi-Fi Direct device `p2p-dev-wlp0s20f3`, which has no kernel netdev (no `/proc/sys/net/ipv4/conf/p2p-dev-wlp0s20f3`). Once per boot/resume; also on boot -2 (pre-update). Silence if ever needed: NM `unmanaged-devices=type:wifi-p2p` (loses Wi-Fi Direct).
      `device (p2p-dev-wlp0s20f3): error setting IPv4 forwarding to '0': Resource temporarily unavailable`
- [x] **wpa_supplicant** — harmless, left as is: multicast RX = kernel extack, iwlwifi/mac80211 lacks multicast mgmt-frame RX registration, once per interface per start, also boot -2 (pre-BIOS). PKCS11 = wpa_supplicant 2:2.12-2 (with openssl 3.6.4 → 4.1.0) tries OpenSSL `pkcs11` provider at TLS init, `pkcs11-provider` not installed; only matters for PKCS#11 EAP-TLS, 0 802.1x connections. Silence if ever needed: `pacman -S pkcs11-provider`.
      `wlp0s20f3: nl80211: kernel reports: multicast RX registrations are not supported` (also p2p-dev-wlp0s20)
      `PKCS11 provider not present` **(new, 7.3.5)**, after wpa_supplicant 2:2.12-1 → 2:2.12-2

### 4. Boot-time one-offs, likely harmless (firmware quirks / informational)

- [x] `CPU topo: [Firmware Bug]: APIC enumeration order not specification compliant` / `Boot CPU APIC ID not the first enumerated APIC ID: 20 != 10` — harmless, left as is: MADT lists APIC 0x10 before boot CPU 0x20; kernel handles it, all 22 CPUs up. BIOS-only fix. Pre-BIOS state unknown (boot -2 early log rotated).
- [x] `intel-hid INTC1077:00: failed to enable HID power button` — harmless, left as is: firmware advertises 5-button array but ACPI `BTNE` fails; power button works via ACPI `PNP0C0C:00` (PWRB) + logind. Firmware-only fix.
- [x] `hpet_acpi_probe: no address or irqs in _CRS` — harmless, left as is: kernel force-disables HPET (`HPET dysfunctional in PC10`), clocksource `tsc`; `/dev/hpet` driver then finds no resources in ACPI `_CRS`.
- [x] `i8042: PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp` — harmless, left as is: ACPI has only PS/2 keyboard `PNP0303:PS2K`; touchpad is I2C HID (`FTCS0038:00`, hid-multitouch), no PS/2 mouse exists.
- [x] `resource: resource sanity check: requesting [mem 0x00000000fedc0000-0x00000000fedcffff], which spans more than PNP0C02:03 [mem 0xfedc0000-0xfedc7fff]` (also `...-0x00000000feddffff`) — not on 7.3.5 boot — gone on 7.3.5 (same source as igen6 below, kernel no longer logs it); harmless, left as is.
- [x] `caller igen6_probe+0xbb/0xb34 [igen6_edac] mapping multiple BARs` (2) — 7.3.5: 3× (`igen6_probe+0x9e/0xbd6`, `+0x13a`, `+0x256`) — harmless, left as is: `igen6_edac` maps MC0/MC1 MCHBAR registers beyond ACPI-reserved `PNP0C02:03` (`fedc0000-fedc7fff`); EDAC MC0/MC1 registered, ce_count 0.
- [x] `spi-nor spi0.0: supply vcc not found, using dummy regulator` — harmless, left as is: BIOS flash `vcc` rail firmware-managed, not described in ACPI; flash works (`/dev/mtd0` "BIOS").
- [x] `ov02c10 i2c-OVTI02C1:00: supply dovdd not found, using dummy regulator` / `supply dvdd not found` — harmless, left as is: webcam sensor; INT3472 describes only `avdd`, `dovdd`/`dvdd` hard-wired; driver bound to `intel_ipu6_isys`.
- [x] `skl_hda_dsp_generic skl_hda_dsp_generic: hda_dsp_hdmi_build_controls: no PCM in topology for HDMI converter 3` — harmless, left as is: MTL display-audio codec has 4 converters, `sof-hda-generic-4ch.tplg` defines 3 HDMI PCMs; HDMI1-3 sinks work.
- [x] `skl_hda_dsp_generic skl_hda_dsp_generic: ASoC: Parent card not yet available, widget card binding deferred` — harmless, left as is: topology widgets load before card registers, ASoC binds them afterwards; card `sof-hda-dsp` fine.
- [x] `virt/tdx: TDX not supported by the host platform` — harmless, left as is: kernel built with TDX host support, server-only feature, absent on Core Ultra 9 185H.
- [x] `ENERGY_PERF_BIAS: Set to 'normal', was 'performance'` — harmless, left as is: kernel `intel_epb` resets BIOS EPB 0 to 6 by design; intel_pstate EPP `balance_performance`.
- [x] ``warning: `ThreadPoolForeg' uses wireless extensions which will stop working for Wi-Fi 7 hardware; use nl80211`` — harmless, left as is: Chromium/Electron `ThreadPoolForegroundWorker` thread (Chromium, Element at login) reads Wi-Fi SSID via legacy wext ioctls; kernel warns once per boot; AX211 is Wi-Fi 6E, unaffected.
- [x] `  #2  #4  #5  #7  #9 #11` — SMP boot CPU-list continuation, split by interleaved `core: cpu_atom PMU driver` lines, so logged at default (warning) level. Cosmetic. Also on 7.2.3 boot, was missing from list. Left as is.
- [x] `v4l2loopback: loading out-of-tree module taints kernel.` — expected, upstream dkms module from the v4l2 fix (replaces the `v4l2loopback_dc` line) Left as is.

### 5. Appeared later on 7.3.5 boot (found 2026-11-21, uptime ~1 h)

- [x] **ags GTK accelerator assertions** (48, bursts of 6, 00:09–00:54; 0 on 7.2.3 boot) — fixed: `~/.config/ags/js/right_left.js` sets a `Gtk.AccelGroup` on each tray menu's dbusmenu client on systemtray `added` (before async layout). Cause: Heroic tray menu has 3 items with `shortcut` (Reload/Debug/Quit); agsv1 `DbusmenuGtk3.Menu` had no accel group, libdbusmenu-gtk passed NULL to `gtk_widget_set_accel_path`/`gtk_widget_add_accelerator`. Verified: 6 ags restarts with Heroic in tray, 0 (before: 6 per restart).
      `gtk_widget_add_accelerator: assertion 'GTK_IS_ACCEL_GROUP (accel_group)' failed`
      `gtk_widget_set_accel_path: assertion 'GTK_IS_ACCEL_GROUP (accel_group)' failed`
- [x] **CPU package thermal throttling** (0 on 7.2.3 boot, ~23 h) — counters at 64 min uptime: 38185 package events, 183 s throttled total, max 5.3 s — harmless, left as is. Cause: internal TCC (TjMax 110, TCC offset 4, activation 106 °C), not external PROCHOT (`0x1B1` bit 2 = 0, `0x64F` PROCHOT log 0). Hotspots on favored 5.1 GHz P-cores (cpu1-4 hold nearly all core throttle events) reach 101+ °C in <20 ms bursts while package ~60 °C; counters climb even near idle (4508 events in 7 min on 2026-11-24 boot). Kernel logs only sustained episodes: 11-21 00:45 (Heroic game), 11-23 14:10, 11-23 20:14. 7.2.3 boot had no game, counters not recorded: no evidence of BIOS/kernel regression. Contributors: tlp PRF on AC (`platform_profile=performance`, EPP `balance_performance`), EC PL1 42 W / PL2 64 W. Fan unreadable (`\VFAN._FST` bug), ideapad `fan_mode` = 16 (undocumented). Alternative if needed: tlp drop-in `TLP_PROFILE_AC=BAL`.
      `CPU5: Package temperature is above threshold, cpu clock is throttled (total events = 35494)`
- [x] **playerctld** (at login; previously only noted under ags media item) — harmless, left as is. Cause: playerctld 2.4.1 (`playerctl-daemon.c:1051-1083`) calls `GetAll` for all 4 MPRIS interfaces whenever an `org.mpris.MediaPlayer2.*` name appears; TrackList/Playlists are optional and most players lack them, so 2 warnings per player appearance. Login pair = mpd-mpris.service start (reproduced with `gdbus call ... GetAll org.mpris.MediaPlayer2.TrackList`). Same pair on 7.2.3 boot. Other variants, same cause: Brave `org.freedesktop.DBus.Error.Failed: error occurred in GetAll`, GDBus players `InvalidArgs: No such interface “org.mpris.MediaPlayer2.TrackList”`; `could not update player position: ...NameHasNoOwner` = player exited right after PropertiesChanged. No upstream fix; `LogFilterPatterns=` is system-services only; disabling playerctld would change Hypr `playerctl` binds (most-recent-player selection).
      `could not get properties for active player: GDBus.Error:org.freedesktop.DBus.Properties.Error.InterfaceNotFound: Error return with empty body:`
- [x] **bluetoothd policy fallback** (5, ~2 s after each DualSense connect) — harmless, left as is. Cause: bluez 5.88 regression, commit f3f03d7285 "policy: Connect profiles for bonded inbound ACL connections": every bonded BR/EDR connect without A2DP arms a 2 s grace timer, then `btd_device_connect_services()`; DualSense has only HID (already connected) + PnP, empty pending list, `connect_next()` returns `-ENOENT`. Nothing attempted, no effect. No main.conf knob; not fixed on master as of 2026-11-24. Cosmetic alternative if it bothers: `LogFilterPatterns=~Fallback profile connection failed: No such file or directory` drop-in for bluetooth.service.
      `plugins/policy.c:policy_grace_timeout() Fallback profile connection failed: No such file or directory (2)`
- [x] **amdgpu resizable BAR fails on eGPU** (2, each boot with dock; previously filed under Thunderbolt item) — amdgpu tries BAR 0 256M to 8G, upstream TB bridges hold other assigned resources, `can't assign; no space`, falls back to 256M. VRAM 8G works. Harmless, left as is (`amdgpu.rebar=0` would only skip the failing attempt; `pci=realloc` for a real 8G BAR not worth it over TB3 x4).
      `pcieport 0000:01:00.0: bridge window [mem 0x4010000000-0x48201fffff 64bit pref]: was not released (still contains assigned resources)`
      `pcieport 0000:00:07.0: bridge window [mem 0x4010000000-0x482fffffff 64bit pref]: was not released (still contains assigned resources)`

### 6. Found in recount 2026-11-24 (boot 2026-11-24 18:02, uptime ~1 h, Thunderbolt dock attached)

Counts per boot: b-2 = 7.2.3, b-1 = 7.3.5 (2026-11-20 23:59), b0 = current.

- [x] **ags progress bar fraction out of range** (b-1 39, b0 1; ~2 s after resume) — fixed: `~/.config/ags/js/right_center.js` network ProgressBar binds `Utils.merge([network.bind("primary"), network.wifi.bind("strength")])`, clamps with `Math.max(strength, 0)`. Cause: agsv1 1.9.0 `service/network.ts:170` `get strength() { return this._ap?.strength || -1; }`, -1/100 while wifi has no access point after resume; old binding also never followed strength changes. Verified: `nmcli connection down/up` on wifi, before 1 warning, after 0; ags restart clean.
      `value "-0.010000" of type 'gdouble' is invalid or out of range for property 'fraction' of type 'gdouble'`
- [x] **IPU6 camera CSI-2 frame sync** (b0 6, 0 before; 18:14:56-18:28:39, camera streaming) + xdg-desktop-portal at 18:14:39 — harmless, left as is. Frame sync: one per camera stream start, 150-200 ms after libcamera `configuring streams`, then frames flow (`Debayer processed 30 frames` 18:17:03). IPU6 CSI-2 receiver flags the first partial frame after ov02c10 stream-on; sensor/driver quirk, no local fix. 0 on earlier boots only because camera was unused there: libcamera + pipewire-libcamera installed 18:14:29 this boot (b-1 wireplumber: `PipeWire's libcamera SPA plugin is missing or broken`). Portal line: one-off, PipeWire user services restarted 18:14:39 (after the install; pacman finished 18:14:32), xdg-desktop-portal lost its connection.
      `intel_ipu6_isys.isys intel_ipu6.isys.40: csi2-0 error: Frame sync error`
      `Caught PipeWire error: connection error`
- [x] **xdg-desktop-portal-gtk parent window** (b0 2, 18:16:55) — harmless, left as is. Chromium (started 18:16:53) asked for camera access; xdg-desktop-portal shows the AccessDialog via gtk backend (`hyprland-portals.conf`: `default=hyprland;gtk`). Chromium passed an empty parent-window handle `""`: x-d-p-gtk 1.15.3 `access.c:281` only skips NULL, `externalwindow.c:78` accepts only `x11:`/`wayland:` prefixes, so both warnings (trailing handle is empty). Dialog shown unparented, approved, stream started 18:17:00. Chromium-side, no local fix; 0 on earlier boots (no camera use).
      `Unhandled parent window type`
      `Failed to associate portal window with parent window`
- [x] **fprintd verification cancelled** (b-2 1, b-1 9, b0 1) — harmless, left as is. hyprlock starts fingerprint verify after resume (`fprint: started verifying` 18:04:01), password unlock wins (`auth: authenticated for hyprlock` 18:04:05), fprintd stops the pending verify.
      `Verification was in progress, stopping it`
- [x] **journald files corrupted** (b0 2, at boot) — harmless, left as is. Previous boot entered s2idle 2026-11-24 01:01:52 (`PM: suspend entry (s2idle)`, last entry) and never resumed: battery drained flat (8% when charging at this boot), so unclean shutdown; journald rotated the files.
      `File /var/log/journal/30a34ad1ad5d42ee8e8b74c57c1c1c2e/system.journal corrupted or uncleanly shut down, renaming and replacing: Device or resource busy`
      `File /var/log/journal/30a34ad1ad5d42ee8e8b74c57c1c1c2e/user-1000.journal corrupted or uncleanly shut down, renaming and replacing: Device or resource busy`

Found in second pass 2026-11-24 (18:30-22:45, same boot):

- [x] **eGPU dock surprise unplug** (20:47:42, `thunderbolt 0-3: device disconnected` while in use) — harmless, left as is: expected noise when the dock is pulled live (amdgpu SMU/PSP/MES errors, HDMI audio CORB, dock xhci, pipewire card removal).
      `amdgpu 0000:05:00.0: device lost from bus!`
      `amdgpu 0000:05:00.0: MES failed to respond to msg=REMOVE_QUEUE`
      `snd_hda_intel 0000:05:00.1: CORB reset timeout#2, CORBRP = 65535`
      `xhci_hcd 0000:06:00.0: HC died; cleaning up`
- [x] **eGPU replug vmemmap hugepage** (22:40:04, with call trace in `kgd2kfd_init_zone_device`) — harmless, left as is: no 2 MB contiguous block after long uptime, kernel falls back to base pages; amdgpu fine (`HMM registered 8176MB device memory`, `Initialized amdgpu 3.64.0 for 0000:05:00.0 on minor 2`).
      `irq/122-pciehp: vmemmap alloc failure: order:9, mode:0x4cc0(GFP_KERNEL|__GFP_RETRY_MAYFAIL), nodemask=(null),cpuset=/,mems_allowed=0`
- [x] **syncthing hashing** (11, archive folder, travel videos) — harmless, left as is: files rewritten while hashed (likely vidcompress re-encode), rescanned later.
      `Failed to scan (path="…" error="hashing: file changed during hashing" folder.label=archive folder.id=wp5xy-z6onw folder.type=sendreceive log.pkg=model)`
- [x] **ags bandwidth script** (3, 19:36:05) — fixed: `~/.config/ags/scripts/bandwidth` writes `~/.cache/netlog` via tmp file + `mv -f` (atomic). Cause: 1 s ags poll spawns a new run each tick; under heavy load (ffmpeg re-encode, 2h31m CPU in 11m51s) runs overlap, `>` truncation let a parallel run read empty `prevdata`. Verified on copy and real script: 4×300 parallel runs, before 12 errors, after 0, no leftover tmp files.
      `/home/earthian/.config/ags/scripts/bandwidth: 32: arithmetic expression: expecting primary: "(rxcurrent - ) / 1024"`
- [x] **foot OSC 256 again** (10 this boot, at each unlock after resume: 18:04:05, 20:21:58-59) — harmless, left as is. Source: `~/.local/bin/change-theme` runs `wal`; pywal 3.3.0 `sequences.send()` writes the palette (incl. `set_color(256, special foreground)`) into every `/dev/pts/*`, one warning per open foot terminal per run; foot applies all other colors. Triggered after resume by `hypridle.conf` `on_unlock_cmd` (`after_sleep_cmds`) and the 300 s listener `on-resume`, so 2 runs per resume. Fix if wanted: `wal -s` + send `sed`-stripped `~/.cache/wal/sequences` to `/dev/pts/*` from change-theme.
      `osc: invalid OSC 4 color index: 256`
- [x] **bluetoothd A2DP SEP rejected** (once per connect of Marshall WOBURN II speaker 00:12:6F:FF:2B:45; b 11-20: 5 connects, b 11-24: 2) — harmless, left as is. `Bad State (49)` = AVDTP 0x31: speaker reconnects on its own and configures its stream while bluetoothd also sends SET_CONFIGURATION; collision, BlueZ drops its cached remote SEPs and the speaker's configuration wins. `Unable to select SEP` (2 of 7 connects) ~2.6 s later, likely bluez 5.88 policy grace-timer fallback (see section 5 item) hitting the just-invalidated cache. Audio works: stream fd `sep5/fd0 ... ready` on playback in both kinds of connect (e.g. 11-22 21:05:04 reject + SEP error, stream 21:05:53). No config knob; speaker firmware behaviour. No baseline: speaker not used on 7.2.3 boot.
      `profiles/audio/avdtp.c:avdtp_parse_rej() SET_CONFIGURATION request rejected: Bad State (49)`
      `profiles/audio/a2dp.c:a2dp_select_capabilities() Unable to select SEP`

### 7. Recount 2026-11-25 (boot 2026-11-25 00:47, uptime ~25 min, after host_reset revert)

- [x] **ESP random seed world-readable** (2, at boot; first time `systemd-boot-random-seed.service` actually ran, skipped on earlier boots) — `/boot` vfat mounted `fmask=0022,dmask=0022` (fstab), `/boot/loader/random-seed` is `-rwxr-xr-x` — left as is (user choice, single-user laptop). Fix if wanted: fstab `/boot` `fmask=0077,dmask=0077`, `umount /boot && mount /boot`.
      `Mount point '/boot' which backs the random seed file is world accessible, which is a security hole!`
      `Random seed file '/boot/loader/.#bootctlrandom-seed3d1ddbc69d1fd274' is world accessible, which is a security hole!`
- [x] **Dock eject + replug** (00:58:22-37) — harmless, left as is: user ran `sudo tee /sys/bus/pci/devices/0000:01:00.0/remove` (eGPU dock eject), then replug at 00:58:36. TB router was runtime-suspended when the link went, hence "lost during suspend". Bridge-window lines = known amdgpu BAR item (section 6).
      `spa.alsa: 0x563ee8fd2128: poll fd error/hangup (card removed?), removing poll sources`
      `thunderbolt 0000:00:0d.2: 0:3: failed to reach state TB_PORT_UP. Ignoring port...`
      `thunderbolt 0000:00:0d.2: 0:3: lost during suspend, disconnecting`
- [x] **playerctld emms** (4, 00:53:47-00:54:07) — harmless, left as is: same root as section 5 playerctld item; Emacs EMMS MPRIS sends PropertiesChanged for TrackList/Playlists it does not implement.
      `Player org.mpris.MediaPlayer2.emms doesn't appear to support interface org.mpris.MediaPlayer2.TrackList, but sent PropertiesChanged regarding its properties.`
      `Player org.mpris.MediaPlayer2.emms doesn't appear to support interface org.mpris.MediaPlayer2.Playlists, but sent PropertiesChanged regarding its properties.`
- [x] **bluetoothd AVDTP stray reply** (1 per boot on b 11-24 and current; 0 before) — harmless, left as is: remote answered an AVDTP request bluetoothd no longer waits for (late reply after timeout/collision, cf. Woburn A2DP item); dropped.
      `profiles/audio/avdtp.c:session_cb() No pending request, ignoring message`

### Recount

    journalctl -b -p warning -o cat | grep -v 'UFW BLOCK' | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -40
