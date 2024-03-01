# nice makefile example: https://github.com/masasam/dotfiles

# run this file with 'sudo -E' to preserve env vars (ie. pwd)
# also there is this var
# .EXPORT_ALL_VARIABLES:

PACMAN := sudo pacman -S --noconfirm
YAY    := yay -S --noconfirm
SSEN   := sudo systemctl --now enable
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

yay: ## install yay aur helper
	@export YAYDIR=${HOME}/utils/$@; \
	if [ ! -d "$$YAYDIR" ]; then \
		mkdir -p $$YAYDIR; \
		git clone https://aur.archlinux.org/$@.git $$YAYDIR; \
		cd $$YAYDIR && makepkg -si --noconfirm; \
		yay --version; \
	fi

pacman: ## add user pacman config to [options] section, add community and multilib repos
	@if [ -z "$$(grep '\[community\]' /etc/$@.conf)" ]; then \
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
		cp $(PACMAN_DIR)/pkglist.txt $(PACMAN_DIR)/temp1.txt
	fi
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
# remove orphaned packages, otherwise rust and rustup are in conflict
	pacman -Qtdq | sudo pacman -Rns --noconfirm -
	rm $(PACMAN_DIR)/temp1.txt

aur-install: yay ## Install all AUR packages
	if [ ! -f $(PACMAN_DIR)/temp2.txt ]; then
		cp $(PACMAN_DIR)/foreignpkglist.txt $(PACMAN_DIR)/temp2.txt
	fi
	export MAKEFLAGS="-j$$(nproc)"
	$(YAY) - < ${HOME}/.config/pacman/temp2.txt
	rm $(PACMAN_DIR)/temp2.txt

reflector:
	$(PACMAN) reflector
	$(SSEN) reflector.timer

install: dotfiles reflector pacman-install yay-install ## Install all packages

postinstall: sysoptions zsh emacs systemd hyprplugins wal golang

postreboot: mpv mpd

# Targets to run manually:
# - floorp : run after first browser launch (cuz folder needs to be created)
# - protonge : run only after steam launch cuz steam creates symlink to root dir
# - icons : run only after you synced icons folder from other devices
# - waydroid : not ready yet
# - asus: for asus laptop
# - xiaomi: for nvidia hybrid xiaomi laptop


# ------------  Packages  ------------

zsh:
	chsh -s /usr/bin/zsh

wal: ## for hyprland to not show error of undefined color var on first launch
	wal -n -q -i "${HOME}/dotfiles/assets/wallpaper.jpg" --saturate 0.3

emacs:
	git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs ${HOME}/.config/$@
	${HOME}/.config/$@/bin/doom install
	${HOME}/.config/$@/bin/doom sync
	rm -rf ${HOME}/.$@.d

floorp:
	find ${HOME}/.floorp/ -maxdepth 1 -type d -name '*.default-release' \
		-exec ln -s $(XDG_CONFIG_HOME)/firefox/user.js {}/user.js \;

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

# TODO:
# hyprplugins:
# 	hyprpm add https://github.com/VortexCoyote/hyprfocus <- doesn't work yet

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

# ------------  Other  ------------

systemd: ## enable and start all user and system systemd services
	$(SSEN) systemd-timesyncd.service
	sudo sed -i '/^ConditionACPower/d' /usr/lib/systemd/system/plocate-updatedb.service
	$(SSEN) plocate-updatedb.timer
	$(SSEN) bluetooth.service
# sequence of these 2 needs to be hardcoded sadly
	$(SUEN) eww.service
	$(SUEN) eww-window@topbar.service
	find ${HOME}/.config/systemd/user/ -type f -printf "%f\n" |
		xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service
	$(SUEN) mpd-mpris.service
	$(SUEN) goimapnotify@mail.service

# system files changed
sysoptions: ## make changes to system files
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
  # =/etc/bluetooth/main.conf= <- AutoEnable=false
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf
	sudo grub-mkconfig -o /boot/grub/grub.cfg
	sudo sed -i 's/^#\(UserspaceHID\)=.*/\1=true/' /etc/bluetooth/input.conf

# TODO: doesn't apply to everything that way yet
icons: ## setup icons and theme
	bash ${HOME}/.icons/unpack-all
	nwg-look -a

asus: ## install ASUS laptop specific software (ie. battery threshold)
# support for vulkan api
	$(PACMAN) --needed needed mesa lib32-mesa mesa-vdpau libva-mesa-driver \
		vulkan-radeon vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
	$(YAY) asusctl amdgpu_top-bin
	wget -P ${HOME}/Downloads https://gitlab.com/asus-linux/asusctl/-/raw/d0b9aee85a60f0d0a1afb4cb6e3da802cddb1344/data/asusd-alt.service
	sudo systemctl mask asusd
	sudo systemctl stop asusd
	sudo cp -p asusd-alt.service /etc/systemd/system/
	$(SSEN) asusd-alt.service
	asusctl -c 80

xiaomi: nvidia-tkg ## install stuff for nvidia hybrid laptop
	$(PACMAN) --needed intel-media-driver nvtop nvidia-prime
	$(YAY) libva-nvidia-driver-git

nvidia-tkg:
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

protonge: ## install proton GE latest version
	export WORKDIR="/tmp/proton-ge-custom"
	mkdir $$WORKDIR
	cd $$WORKDIR
# download  tarball
	curl -LOJ "$$(curl https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
# download checksum
	curl -LOJ "$$(curl https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
	sha512sum -c ./*.sha512sum
	mkdir -p ${HOME}/.steam/root/compatibilitytools.d
	tar -xf GE-Proton*.tar.gz -C ${HOME}/.steam/root/compatibilitytools.d/
	cd /
	rm -rf $$WORKDIR
	echo "All done :)"

# useful when removed some file(s) from repo and don't want to remove the
# symlinks by hand
clean: ## removes all broken symlinks recursively
	cd ${HOME}
	find . -path ./.local/share -prune -o -path ./.cache -prune -o -xtype l -print |
		xargs rm
