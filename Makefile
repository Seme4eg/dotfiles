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
# if this special target appears anywhere in the makefile then *all* recipe
# lines for each target will be provided to a single invocation of the shell.
.ONESHELL:

# prevents 'make' from getting confused by an actual file called 'allinstall',
# etc.. and causes it to continue in spite of errors
# .PHONY: all allinstall nextinstall allupdate allbackup

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test:
	export SSHDIR="${HOME}/.$@"
	echo $$XDG_DATA_HOME
	echo $(XDG_DATA_HOME)

# --- Runned manually ---

# generate new ssh every time
ssh: ## Init ssh
	export SSHDIR=${HOME}/.$@
	$(PACMAN) open$@
	mkdir -p $$SSHDIR
	ssh-keygen -C "418@duck.com" -P ""
# create AUR keypair
	ssh-keygen -f $$SSHDIR/aur
	eval "$$(ssh-agent -s)"
	ssh-add $$SSHDIR/id_ed25519
	chmod 600 $$SSHDIR/id_ed25519
	curl -F 'file=@-' 0x0.st < $$SSHDIR/id_ed25519.pub

pacman: ## add user pacman config to [options] section, add community and multilib repos
	@if [ -z "$$(grep '\[community\]' /etc/$@.conf)" ]; then \
		sudo sed -i '/^Architecture/ a\Include = ${HOME}/.config/$@/$@.conf' /etc/$@.conf; \
		echo '
		[community]
		Include = /etc/pacman.d/mirrorlist

		[multilib]
		Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/$@.conf; \
	fi

# useful when removed some file(s) from repo and don't want to remove the
# symlinks by hand
clean: ## removes all broken symlinks recursively
	cd ${HOME}
	find . -path ./.local/share -prune -o -path ./.cache -prune -o -xtype l -print |
		xargs rm


# --- 3 main stages ---

install: dotfiles reflector pacman-install aur-install

postinstall: sysoptions zsh emacs systemd zram hyprplugins wal golang pam-gnupg ags pnpm

postreboot: mpv mpd

# --- Install ---

dotfiles: ## Initial deploy dotfiles
	mkdir -p ${HOME}/.local/share/applications
	mkdir -p ${HOME}/.local/share/fonts
	mkdir -p ${HOME}/.local/bin
	mkdir -p ${HOME}/.ssh
# or otherwise unsave permissions
	mkdir -p -m700 ${HOME}/.gnupg
	$(PACMAN) git stow
	git clone git@github.com:Seme4eg/$@.git ${HOME}/$@
	rm Makefile
	cd ${HOME}/$@
	stow .
# clone doom config repo before secrets one cuz latter one contains
# file that should be in doom config dir
	git clone git@github.com:Seme4eg/.doom.d.git ${HOME}/.config/doom
# potentially must be a different rule
	git clone git@github.com:Seme4eg/secrets.git ${HOME}/secrets
	cd ${HOME}/secrets
	stow .

reflector:
	$(PACMAN) reflector
	$(SSEN) reflector.timer

PACMAN_DIR := ${HOME}/.config/pacman
pacman-install: ## Install all pacman packages
	if [ ! -f $(PACMAN_DIR)/temp1.txt ]; then
		cp $(PACMAN_DIR)/pkglist.txt $(PACMAN_DIR)/temp1.txt
	fi
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
# remove orphaned packages, otherwise rust and rustup are in conflict
	pacman -Qtdq | sudo pacman -Rns --noconfirm -
	rm $(PACMAN_DIR)/temp1.txt

yay: ## install yay aur helper
	@export YAYDIR=${HOME}/utils/$@; \
	if [ ! -d "$$YAYDIR" ]; then \
		mkdir -p $$YAYDIR; \
		git clone https://aur.archlinux.org/$@.git $$YAYDIR; \
		cd $$YAYDIR && makepkg -si --noconfirm; \
		yay --version; \
	fi

aur-install: yay ## Install all AUR packages
	if [ ! -f $(PACMAN_DIR)/temp2.txt ]; then
		cp $(PACMAN_DIR)/foreignpkglist.txt $(PACMAN_DIR)/temp2.txt
	fi
	export MAKEFLAGS="-j$$(nproc)"
	$(YAY) - < ${HOME}/.config/pacman/temp2.txt
	rm $(PACMAN_DIR)/temp2.txt


# --- Postinstall ---

# system files changed
sysoptions: ## make changes to system files
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf
	sudo grub-mkconfig -o /boot/grub/grub.cfg
	sudo sed -i 's/^#\(UserspaceHID\)=.*/\1=true/' /etc/bluetooth/input.conf
# fix dualsense controller connection
# https://github.com/bluez/bluez/issues/673#issuecomment-2156084398
	sudo sed -i 's/^#\(ClassicBondedOnly\)=.*/\1=false/' /etc/bluetooth/input.conf
# for ags bluetooth service battery percentage
	sudo sed -i 's/^#\(Experimental\) = .*/\1 = true/' /etc/bluetooth/main.conf

zsh:
	chsh -s /usr/bin/zsh

emacs:
	git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs ${HOME}/.config/$@
	cd ${HOME}/.config/doom/emacsbuild
	makepkg --install
	${HOME}/.config/$@/bin/doom install
	${HOME}/.config/$@/bin/doom sync
	rm -rf ${HOME}/.$@.d

systemd: ## enable and start all user and system systemd services
	$(SSEN) systemd-timesyncd.service
	sudo sed -i '/^ConditionACPower/d' /usr/lib/systemd/system/plocate-updatedb.service
	$(SSEN) plocate-updatedb.timer
	$(SSEN) bluetooth.service
	find ${HOME}/.config/systemd/user/ -type f -printf "%f\n" |
		xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service
	$(SUEN) goimapnotify@mail.service

# man zram-generator.conf
# zram-size = min(ram / 2, 4096) # default
# compression-algorithm = zstd # kernel default, see 'zramctl zram0' for which
#   algorith is being used.
zram: ## enable zram
	@echo '[zram0]' | sudo tee /etc/systemd/zram-generator.conf > /dev/null
	$(SSER) systemd-zram-setup@zram0

hyprplugins:
	hyprpm update
	hyprpm add https://github.com/VortexCoyote/hyprfocus
	hyprpm enable hyprfocus
	hyprpm add https://github.com/ItsDrike/hyprland-dwindle-autogroup
	hyprpm enable dwindle-autogroup
	hyprpm reload

wal: ## for hyprland to not show error of undefined color var on first launch
	wal -n -q -i "${HOME}/dotfiles/assets/wallpaper.jpg" --saturate 0.3

golang: ## install go and its packages
	$(PACMAN) go
	export GOPATH="${HOME}/go"
# needed for doom golang setup to work
	go install golang.org/x/tools/gopls@latest
	go install github.com/x-motemen/gore/cmd/gore@latest
	go install github.com/stamblerre/gocode@latest
	go install golang.org/x/tools/cmd/godoc@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install golang.org/x/tools/cmd/gorename@latest
	go install golang.org/x/tools/cmd/guru@latest
	go install github.com/cweill/gotests/gotests@latest
	go install github.com/fatih/gomodifytags@latest
# for formatting docker files in emacs
	go install github.com/jessfraz/dockfmt@latest
# for debugging
	go install github.com/go-delve/delve/cmd/dlv@latest

pam-gnupg: ## setup pam-gnupg to unlock GnuPG keys on login
	@echo 'auth     optional  pam_gnupg.so store-only' | sudo tee -a /etc/pam.d/system-local-login > /dev/null
	@echo 'session  optional  pam_gnupg.so' | sudo tee -a /etc/pam.d/system-local-login > /dev/null

ags:
	ags --init
	sass --no-source-map $(XDG_CONFIG_HOME)/ags/styles/main.scss $(XDG_CONFIG_HOME)/ags/compiled.scss

pnpm: ## install all needed global npm packages
	export PNPM_HOME=${HOME}/.pnpm
	export PATH=$$PNPM_HOME:$(PATH)
	pnpm add --global prettier
	pnpm add --global typescript-language-server
	pnpm add --global typescript
	pnpm add --global yaml-language-server
	pnpm add --global bash-language-server
	pnpm add --global vscode-json-languageserver
	pnpm add --global vscode-langservers-extracted
	pnpm add --global dockerfile-language-server-nodejs


# --- Postreboot ---

mpv:
	git --no-pager --literal-pathspecs -c core.preloadindex\=true -c log.showSignature\=false \
		-c color.ui\=false -c color.diff\=false submodule update --init -- .config/mpv
	emacsclient -e '(progn (require (quote org)) (org-babel-tangle-file "$(XDG_CONFIG_HOME)/$@/README.org"))'
# previous command creates .emacs.d, lazy to find out why so just delete it
	rm -rf ${HOME}/.emacs.d
	cd $(XDG_CONFIG_HOME)/$@
	./mpvmanager

mpd:
	mkdir -p ${HOME}/.$@
	systemctl --user restart $@.service
	$(SUEN) mpd.service


# ------------  Targets to run manually  ------------

floorp: ## run after first browser launch (cuz folder needs to be created)
	find ${HOME}/.floorp/ -maxdepth 1 -type d -name '*.default-release' \
		-exec ln -s $(XDG_CONFIG_HOME)/firefox/user.js {}/user.js \;

icons: ## setup icons and theme (run only after you synced icons folder from other devices)
	bash ${HOME}/.icons/unpack-all
	nwg-look -a

asus: ## install ASUS laptop specific software (ie. battery threshold)
# support for vulkan api
	$(PACMAN) --needed needed mesa lib32-mesa mesa-vdpau libva-mesa-driver \
		vulkan-radeon vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
	$(YAY) asusctl amdgpu_top-bin
	asusctl -c 80

xiaomi: nvidia-all ## install stuff for nvidia hybrid laptop
	$(PACMAN) --needed intel-media-driver libva-utils nvtop nvidia-prime
	$(YAY) libva-nvidia-driver-git

nvidia-all: ## nvidia-tkg
	rm -rf ${HOME}/utils/$@
	git clone https://github.com/Frogging-Family/nvidia-all.git ${HOME}/utils/$@
	cd ${HOME}/utils/$@
	makepkg -si

Fooocus: ## download and setup fooocus (https://github.com/lllyasviel/Fooocus)
	$(YAY) miniconda3
	git clone https://github.com/lllyasviel/Fooocus.git ${HOME}/utils/$@
	cd ${HOME}/utils/Fooocus
	conda env create -f environment.yaml
	conda activate fooocus
	pip install -r requirements_versions.txt
