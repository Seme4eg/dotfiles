# nice makefile example: https://github.com/masasam/dotfiles

# run this file with 'sudo -E' to preserve env vars (ie. pwd)
# also there is this var
# .EXPORT_ALL_VARIABLES:

SHELL := /bin/bash
.SHELLFLAGS := -ec
# if this special target appears anywhere in the makefile then *all* recipe
# lines for each target will be provided to a single invocation of the shell.
.ONESHELL:

PACMAN := sudo pacman -S --noconfirm
YAY    := yay -S --noconfirm
SSEN   := sudo systemctl --now enable
SSER   := sudo systemctl daemon-reload && systemctl restart
SUEN   := systemctl --user --now enable

.DEFAULT_GOAL := help
# .PHONY:

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test:
	export SSHDIR="${HOME}/.$@"
	echo $$XDG_DATA_HOME
	echo $(XDG_DATA_HOME)

XDG_CONFIG_HOME=${HOME}/.config
XDG_CACHE_HOME=${HOME}/.cache
XDG_DATA_HOME=${HOME}/.local/share
XDG_STATE_HOME=${HOME}/.local/state

# --- Runned manually ---

# generate new ssh every time
ssh: ## Init ssh
	export SSHDIR=${HOME}/.$@
	$(PACMAN) open$@
	mkdir -p $$SSHDIR
	ssh-keygen -C "for github"
# create AUR keypair
	ssh-keygen -f $$SSHDIR/aur
	eval "$$(ssh-agent -s)"
	ssh-add $$SSHDIR/id_ed25519
	chmod 600 $$SSHDIR/id_ed25519
	curl -F 'file=@-' 0x0.st < $$SSHDIR/id_ed25519.pub

cleanhome: .SHELLFLAGS = -c
cleanhome:
	@cd ${HOME}
	@rm -rf ${HOME}/.themes
	@rm -rf ${HOME}/Desktop
	@rm -rf ${HOME}/Public
	@rm -rf ${HOME}/Templates
	@rm -rf ${HOME}/Videos
	@rm -rf ${HOME}/.npm
	@ls .bash* | xargs rm
	@rm .lesshst
	@rm .viminfo
	@rm .wget-hsts

# useful when removed some file(s) from repo and don't want to remove the
# symlinks by hand
cleandeadlinks: ## removes all broken symlinks recursively
	cd ${HOME}
	find . -path ./.local/share -prune -o -path ./.cache -prune -o -xtype l -print |
		xargs rm


# --- 3 main stages ---

install: dotfiles reflector zsh pacman pacman-install aur-install

postinstall: sysoptions emacs systemd wal goinstall gopkgs pam-gnupg ags pnpm \
	earlyoom grubtheme gtk-theme dash steam captive-dispatcher cursor

postreboot: mpv mpd

# --- Install ---

dotfiles: ## Initial deploy dotfiles
	mkdir -p $(XDG_DATA_HOME)/applications
	mkdir -p $(XDG_DATA_HOME)/fonts
	mkdir -p ${HOME}/.local
	mkdir -p ${HOME}/.ssh
# otherwise msmtp fails to create logfile
	mkdir -p $(XDG_CACHE_HOME)/msmtp
# https://github.com/lutris/docs/blob/master/WineDependencies.md#archendeavourosmanjaroother-arch-derivatives
	mkdir -p $(XDG_DATA_HOME)/wineprefixes
# or otherwise unsave permissions
	mkdir -p -m700 ${HOME}/.gnupg
	$(PACMAN) git stow git-crypt
	git clone git@github.com:Seme4eg/$@.git ${HOME}/$@
	rm Makefile
	cd ${HOME}/$@
	git-crypt unlock # FIXME: remove after test on new machine
	git submodule update --init --recursive
	stow .

reflector:
	$(PACMAN) reflector
	$(SSEN) reflector.timer

zsh: ## change shell to zsh, we need those env vars
	$(PACMAN) zsh
	chsh -s /usr/bin/zsh

pacman: ## add user pacman config to [options] section, add multilib repos
	@if [ -z "$$(grep '\[community\]' /etc/$@.conf)" ]; then \
# on init install remove hooks setting otherwise if pacman fails its gonna
# owerwrite the files, which is inconvenient. After successful bootstrap i see
# that change anyway and remove it.
		sed -i '/HookDir/d' ${HOME}/dotfiles/.config/pacman/pacman.conf
		sudo sed -i '/^Architecture/ a\Include = ${HOME}/.config/$@/$@.conf' /etc/$@.conf; \
		echo '
		[multilib]
		Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/$@.conf; \
	fi


pacman-install: ## Install all pacman packages
	if [ ! -f $(XDG_DATA_HOME)/temp1.txt ]; then
		cp $(XDG_DATA_HOME)/pkgspacman $(XDG_DATA_HOME)/temp1.txt
	fi
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
	rm $(XDG_DATA_HOME)/temp1.txt
	tldr --update

yay: ## install yay aur helper
	@export YAYDIR=$(XDG_CACHE_HOME)/$@;
	if [ -d "$$YAYDIR" ]; then
		rm -rf $$YAYDIR
	fi
	mkdir -p $$YAYDIR;
	git clone https://aur.archlinux.org/$@.git $$YAYDIR;
	sudo pacman -Syy
	cd $$YAYDIR && makepkg -si --noconfirm;
	yay --version;

aur-install: yay ## Install all AUR packages
	if [ ! -f $(XDG_DATA_HOME)/temp2.txt ]; then
		cp $(XDG_DATA_HOME)/pkgsaur $(XDG_DATA_HOME)/temp2.txt
	fi
	export MAKEFLAGS="-j$$(nproc)"
	$(YAY) - < ${HOME}/.config/pacman/temp2.txt
	rm $(XDG_DATA_HOME)/temp2.txt


# --- Postinstall ---

# system files changed
sysoptions: ## make changes to system files
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf
	sudo grub-mkconfig -o /boot/grub/grub.cfg
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
# https://wiki.archlinux.org/title/Sysctl
# https://wiki.archlinux.org/title/Swap#Swappiness
	@echo 'vm.swappiness = 10' | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null

emacsbuild: ## build emacs from my PKGBUILD
	cd ${HOME}/.config/doom/emacsbuild
	makepkg -sir

emacs: ## install & sync doom emacs
# TODO: 'if dir is empty / doesn't exist..'
	git clone git@github.com:Seme4eg/.doom.d.git ${HOME}/.config/doom
	cd ${HOME}/.config/doom
	git-crypt unlock
	git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs ${HOME}/.config/$@
	${HOME}/.config/$@/bin/doom install
	${HOME}/.config/$@/bin/doom sync
	rm -rf ${HOME}/.$@.d

systemd: ## enable and start all user and system systemd services
	$(SSEN) systemd-timesyncd.service
	$(SSEN) bluetooth.service
	find ${HOME}/.config/systemd/user/ -type f -printf "%f\n" |
		xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service
	$(SUEN) mpd-mpris.service
	$(SUEN) update_lsps.timer

wal: ## for hyprland to not show error of undefined color var on first launch
	wal -n -q -i "${HOME}/dotfiles/assets/wallpaper.jpg" --saturate 0.3

goinstall: ## install go and export path
	$(PACMAN) go
	export GOPATH="$(XDG_DATA_HOME)/go"

gopkgs: ## install go and its packages
# doom golang setup
	go install golang.org/x/tools/gopls@latest
	go install github.com/x-motemen/gore/cmd/gore@latest
	go install github.com/stamblerre/gocode@latest
	go install golang.org/x/tools/cmd/godoc@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/tools/cmd/gorename@latest
	go install github.com/cweill/gotests/gotests@latest
	go install github.com/fatih/gomodifytags@latest
# emacs docker files formatting
	go install github.com/jessfraz/dockfmt@latest
# debugging
	go install github.com/go-delve/delve/cmd/dlv@latest
# formatting
	go install github.com/segmentio/golines@latest
# +lsp
# go install github.com/nametake/golangci-lint-langserver@latest

pam-gnupg: ## setup pam-gnupg to unlock GnuPG keys on login
	@echo 'auth     optional  pam_gnupg.so store-only' | sudo tee -a /etc/pam.d/system-local-login > /dev/null
	@echo 'session  optional  pam_gnupg.so' | sudo tee -a /etc/pam.d/system-local-login > /dev/null

ags:
	agsv1 --init
	sass --no-source-map $(XDG_CONFIG_HOME)/ags/styles/main.scss $(XDG_CONFIG_HOME)/ags/compiled.scss

pnpm: ## install all needed global npm packages
	export PNPM_HOME=$(XDG_DATA_HOME)/pnpm
	export PATH=$$PNPM_HOME:$(PATH)
	pnpm add --global typescript-language-server
	pnpm add --global typescript
	pnpm add --global yaml-language-server
	pnpm add --global bash-language-server
	pnpm add --global vscode-json-languageserver
	pnpm add --global vscode-langservers-extracted
	pnpm add --global dockerfile-language-server-nodejs

earlyoom:
# earlyoom -h
# without this change notifications won't work
# https://github.com/rfjakob/earlyoom/issues/270#issuecomment-1155020972
	sudo sed -i 's/^\(DynamicUser=true\)/# \1/' /usr/lib/systemd/system/earlyoom.service
	@echo EARLYOOM_ARGS=-m 5 -r 3600 -n --avoid '(^|/)(init|systemd|Hyprland|sshd)$$' --prefer '(^|/)(emacs|librewolf|steam|vesktop)$$' |
		sudo tee /etc/default/earlyoom > /dev/null
	$(SSEN) earlyoom.service

grubtheme: .SHELLFLAGS := -c
grubtheme:
	git clone git@github.com:vinceliuice/Elegant-grub2-themes.git $(XDG_DATA_HOME)/utils/$@
	cd $(XDG_DATA_HOME)/utils/$@
# commit before borked opensuse pngs naming..
	git reset --hard 6cfd864
	sudo ./install.sh -s 2k -b

THEME=$(shell gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")
ICONS=$(shell gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
gtk-theme:
	wpg-install.sh -G
# apply theme
	nwg-look -a
# TODO: line to install flatpak packages from my pkgsflatpak file
# Fix for theming in flatpak applications:
# source: https://web.archive.org/web/20230106121332/https://itsfoss.com/flatpak-app-apply-theme/
	sudo flatpak override --filesystem=$(XDG_DATA_HOME)/themes
	sudo flatpak override --filesystem=$(XDG_DATA_HOME)/icons
	sudo flatpak override --env=GTK_THEME=$(THEME)
	sudo flatpak override --env=ICON_THEME=$(ICONS)

dash: ## symlink sh to dash
	sudo ln -sfT dash /usr/bin/sh

steam: ## prevent steam to create yet another file in my home dir
	@echo 'cookie-file = ~/.config/pulse/cookie' | sudo tee -a /etc/pulse/client.conf > /dev/null

captive-dispatcher: ## install network manager captive portal dispatcher script
	@sudo wget --output-document \
		/etc/NetworkManager/dispatcher.d/90-open_captive_portal \
		'https://raw.githubusercontent.com/Seme4eg/captive-portal-sh/refs/heads/master/90-open_captive_portal'
	@sudo chmod +x /etc/NetworkManager/dispatcher.d/90-open_captive_portal
	@$(SSER) NetworkManager

CURSOR_DIR=${HOME}/dotfiles/.local/share/icons
CURSOR_NAME=BreezeX-RosePine-Linux.tar.xz
cursor: ## setup icons and theme (run only after you synced icons folder from other devices)
	echo "Extracting $(CURSOR_DIR)/$(CURSOR_NAME) .."
	tar -C $(CURSOR_DIR) -xf "$(CURSOR_DIR)/$(CURSOR_NAME)"
	nwg-look -a


# --- Postreboot ---

mpv:
	@git --no-pager --literal-pathspecs -c core.preloadindex\=true -c log.showSignature\=false \
		-c color.ui\=false -c color.diff\=false submodule update --init -- .config/mpv
	@emacsclient -e '(progn (require (quote org)) (org-babel-tangle-file "$(XDG_CONFIG_HOME)/$@/README.org"))'
# previous command creates .emacs.d, lazy to find out why so just delete it
	@rm -rf ${HOME}/.emacs.d
	@cd $(XDG_CONFIG_HOME)/$@
	@./mpvmanager sync

mpd:
	mkdir -p $(XDG_DATA_HOME)/$@
	systemctl --user restart $@.service
	$(SUEN) mpd.service


# ------------  Targets to run manually  ------------

# --- graphics ---

# NOTE: do NOT install 'amdvlk & lib32-amdvlk', those are open-source drivers
# and will take precedence over proprietary ones if installed. Last time i
# bootstrapped the system those got somehow installed along something so do
# check and uninstall them if present. Proprietary drivers give like +10-15%
# more performance. To check which drivers are used: 'vulkaninfo --summary' ->
# driverID should be 'DRIVER_ID_MESA_RADV', not 'DRIVER_ID_AMD_OPEN_SOURCE'
amd: ## install AMD specific software
# support for vulkan api
	@$(PACMAN) --needed --asdeps mesa mesa-utils lib32-mesa mesa-vdpau \
		libva-mesa-driver vulkan-radeon lib32-vulkan-radeon
	@$(YAY) amdgpu_top-bin
	@vulkaninfo --summary | grep -q OPEN_SOURCE && sudo pacman -Rns amdvlk lib32-amdvlk

nvidia-all: ## nvidia-tkg
	rm -rf $(XDG_DATA_HOME)/utils/$@
	git clone https://github.com/Frogging-Family/nvidia-all.git $(XDG_DATA_HOME)/utils/$@
	cd $(XDG_DATA_HOME)/utils/$@
	makepkg -si

nvidia: nvidia-all ## install stuff for nvidia hybrid laptop
	$(PACMAN) --needed intel-media-driver libva-utils nvtop nvidia-prime
	$(YAY) libva-nvidia-driver-git

# --- graphics end ---
#
# --- laptops ---

lenovo: ## lenovo setup
	$(PACMAN) vulkan-intel lib32-vulkan-intel bolt
	sudo ln ${HOME}/.config/tlp/02-lenovo.conf /etc/tlp.d/
	$(SSEN) tlp.service

# --- laptops end ---
#
# --- optional / manual ---

Fooocus: ## download and setup fooocus (https://github.com/lllyasviel/Fooocus)
	$(YAY) miniconda3
	git clone https://github.com/lllyasviel/Fooocus.git $(XDG_DATA_HOME)/utils/$@
	cd $(XDG_DATA_HOME)/utils/$@
	conda env create -f environment.yaml
	conda activate fooocus
	pip install -r requirements_versions.txt

hyprplugins:
	hyprpm update
	hyprpm add https://github.com/VortexCoyote/hyprfocus
	hyprpm enable hyprfocus
	hyprpm add https://github.com/ItsDrike/hyprland-dwindle-autogroup
	hyprpm enable dwindle-autogroup
	hyprpm reload

librewolf: ## setup pywalfox and tridactyl native, see blame if won't work
	pywalfox --browser librewolf install
# path from where to link - https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=firefox-tridactyl-native
	ln -s /usr/lib/mozilla/native-messaging-hosts/tridactyl.json \
		${HOME}/.librewolf/native-messaging-hosts/
	ln -s $(XDG_CONFIG_HOME)/firefox/librewolf.overrides.cfg \
		${HOME}/.librewolf/

XHOME: ## things to enable when i'm home
# zapret settings in secrets
	@sudo systemctl enable --now zapret_discord_youtube
# for zapret to pick up the correct network interface
	@sudo systemctl restart NetworkManager
	@systemctl --user enable --now v2raya-lite
	@sed -i 's/^# \(exec-once = solaar -w hide\)$$/\1/' ${HOME}/dotfiles/.config/hypr/exec-once.conf
	@solaar -w hide
	@sudo chmod 600 cisco.nmconnection
	@sudo cp -f ${HOME}/git/secrets/w_mg/cisco-proxy.nmconnection /etc/NetworkManager/system-connections/cisco.nmconnection
	@sudo nmcli con reload cisco
	@echo "Super-Shift-b" is your friend now
# ================================ IMPORTANT: ================================
# "- set 'gptel-proxy' var in emacs to 'localhost:20171'
# "- for anything that requires proxy now - redirect it to that local v2raya proxy
# "- change tailscale ip to local homelab ip

XHOME-uninstall:
	@sudo systemctl stop zapret_discord_youtube
	@sudo systemctl disable zapret_discord_youtube
	@sudo systemctl restart NetworkManager
	@systemctl --user stop v2raya-lite
	@systemctl --user disable v2raya-lite
	@pkill solaar
	@sudo chmod 600 cisco.nmconnection
	@sudo cp -f ${HOME}/git/secrets/w_mg/cisco.nmconnection /etc/NetworkManager/system-connections/cisco.nmconnection
	@sudo nmcli con reload cisco
	@sed -i 's/^\(exec-once = solaar -w hide\)$$/# \1/' ${HOME}/dotfiles/.config/hypr/exec-once.conf
# ================================ IMPORTANT: ================================
# "- unset 'gptel-proxy' var in emacs
# "- for anything that required proxy - remove it, don't slow down things
# "- change local homelab ip to tailscale one
