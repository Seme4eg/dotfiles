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
cleanhome: .SHELLFLAGS = -c
cleanhome:
	rm -rf ${HOME}/nonexist
	rm -rf ${HOME}/.themes
	rm -rf ${HOME}/Desktop
	rm -rf ${HOME}/Public
	rm -rf ${HOME}/Templates
	rm -rf ${HOME}/Videos
	rm -rf ${HOME}/.npm
	ls .bash* | xargs rm
	rm .lesshst

# useful when removed some file(s) from repo and don't want to remove the
# symlinks by hand
clean: ## removes all broken symlinks recursively
	cd ${HOME}
	find . -path ./.local/share -prune -o -path ./.cache -prune -o -xtype l -print |
		xargs rm


# --- 3 main stages ---

install: dotfiles reflector pacman-install aur-install

postinstall: sysoptions zsh emacs systemd wal goinstall gopkgs \
	pam-gnupg ags pnpm tlp earlyoom grubtheme wpgtk wine-deps dash steam pywalfox

postreboot: mpv mpd

# --- Install ---

dotfiles: ## Initial deploy dotfiles
	mkdir -p ${HOME}/.local/share/applications
	mkdir -p ${HOME}/.local/share/fonts
	mkdir -p ${HOME}/.local/bin
	mkdir -p ${HOME}/.ssh
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
	chsh -s /usr/bin/zsh


pacman: ## add user pacman config to [options] section, add community and multilib repos
	@if [ -z "$$(grep '\[community\]' /etc/$@.conf)" ]; then \
		sed -i '/HookDir/d' ${HOME}/dotfiles/.config/pacman/pacman.conf # XXX explain
		sudo sed -i '/^Architecture/ a\Include = ${HOME}/.config/$@/$@.conf' /etc/$@.conf; \
		echo '
		[community]
		Include = /etc/pacman.d/mirrorlist

		[multilib]
		Include = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/$@.conf; \
	fi


PACMAN_DIR := ${HOME}/.config/pacman
pacman-install: ## Install all pacman packages
	if [ ! -f $(PACMAN_DIR)/temp1.txt ]; then
		cp $(PACMAN_DIR)/pkgspacman $(PACMAN_DIR)/temp1.txt
	fi
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
	rm $(PACMAN_DIR)/temp1.txt

yay: ## install yay aur helper
	@export YAYDIR=$(XDG_DATA_HOME)/utils/$@;
	if [ -d "$$YAYDIR" ]; then
		rm -rf $$YAYDIR
	fi
	mkdir -p $$YAYDIR; 
	git clone https://aur.archlinux.org/$@.git $$YAYDIR; 
	cd $$YAYDIR && makepkg -si --noconfirm; 
	yay --version; 

aur-install: yay ## Install all AUR packages
	if [ ! -f $(PACMAN_DIR)/temp2.txt ]; then
		cp $(PACMAN_DIR)/pkgsaur $(PACMAN_DIR)/temp2.txt
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
# https://wiki.archlinux.org/title/Sysctl
# https://wiki.archlinux.org/title/Swap#Swappiness
	@echo 'vm.swappiness = 10' | sudo tee /etc/sysctl.d/99-sysctl.conf > /dev/null

zsh:
	chsh -s /usr/bin/zsh

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
	go install golang.org/x/tools/cmd/guru@latest
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
	ags --init
	sass --no-source-map $(XDG_CONFIG_HOME)/ags/styles/main.scss $(XDG_CONFIG_HOME)/ags/compiled.scss

pnpm: ## install all needed global npm packages
	export PNPM_HOME=$(XDG_DATA_HOME)/.pnpm
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
	@echo EARLYOOM_ARGS=-m 5 -r 3600 -n --avoid '(^|/)(init|systemd|Hyprland|sshd|abaddon)$' --prefer '(^|/)(emacs|librewolf|steam|legcord)$'
	| sudo tee /etc/default/earlyoom > /dev/null
	$(SSEN) earlyoom.service

grubtheme:
# git clone git@github.com:vinceliuice/Elegant-grub2-themes.git $(XDG_DATA_HOME)/utils/$@
	cd $(XDG_DATA_HOME)/utils/$@
	sudo ./install.sh -s 2k -b

wpgtk:
	wpg-install.sh -G

# https://github.com/lutris/docs/blob/master/WineDependencies.md#archendeavourosmanjaroother-arch-derivatives
wine-deps: ## install wine dependencies for heroic
	mkdir -p "$XDG_DATA_HOME"/wineprefixes
	$(PACMAN) wine-staging
	$(PACMAN) --needed --asdeps giflib lib32-giflib gnutls lib32-gnutls v4l-utils \
		lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins \
		alsa-lib lib32-alsa-lib sqlite lib32-sqlite libxcomposite lib32-libxcomposite \
		ocl-icd lib32-ocl-icd libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs \
		lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader sdl2 \
		lib32-sdl2

dash: ## symlink sh to dash
	sudo ln -sfT dash /usr/bin/sh

steam: ## prevent steam to create yet another file in my home dir
	@echo 'cookie-file = ~/.config/pulse/cookie' | sudo tee -a /etc/pulse/client.conf > /dev/null

pywalfox: ## install pywalfox for librewolf browser, see blame if won't work
	pywalfox --browser librewolf install

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
	mkdir -p $(XDG_DATA_HOME)/$@
	systemctl --user restart $@.service
	$(SUEN) mpd.service


# ------------  Targets to run manually  ------------

# --- graphics ---

amd: ## install ASUS laptop specific software
# support for vulkan api
	$(PACMAN) --needed --asdeps mesa mesa-utils lib32-mesa mesa-vdpau \
		libva-mesa-driver vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader \
		lib32-vulkan-icd-loader
	$(YAY) amdgpu_top-bin

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

asus:
	$(SSEN) tlp.service
	sudo ln ${HOME}/.config/01-asus-tlp.conf /etc/tlp.d/01-asus.conf

lenovo: ## lenovo setup
# XXX: TLP config separately for this laptop

# --- laptops end ---

icons: ## setup icons and theme (run only after you synced icons folder from other devices)
	bash $(XDG_DATA_HOME)/icons/unpack-all
	nwg-look -a

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
