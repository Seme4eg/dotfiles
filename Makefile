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
	ssh-keygen -t ed25519 -C "418@duck.com" -P ""
	eval "$$(ssh-agent -s)"
	ssh-add $$SSHDIR/id_ed25519
	chmod 600 $$SSHDIR/id_ed25519
	curl -F 'file=@-' 0x0.st < $$SSHDIR/id_ed25519.pub

dotfiles: ## Initial deploy dotfiles
	mkdir -p ${HOME}/.local/share/applications
	mkdir -p ${HOME}/.local/share/fonts
	mkdir -p ${HOME}/.local/bin
# or otherwise unsave permissions
	mkdir -p ${HOME}/.gnupg
	chmod 700 ${HOME}/.gnupg
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

reflector:
	$(PACMAN) reflector
	$(SSEN) reflector

PACMAN_DIR := ${HOME}/.config/pacman
install: dotfiles reflector yay pacman ## Install all packages
	if [ ! -f $(PACMAN_DIR)/temp1.txt ]; then
		cp $(PACMAN_DIR)/pkglist.txt $(PACMAN_DIR)/temp1.txt
		cp $(PACMAN_DIR)/foreignpkglist.txt $(PACMAN_DIR)/temp2.txt
	fi
	export MAKEFLAGS="-j$$(nproc)"
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
# heroic dependencies
	$(PACMAN) --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
		mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
		lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
		sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
		ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 \
		lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
# remove orphaned packages, otherwise rust and rustup are in conflict
	pacman -Qtdq | sudo pacman -Rns --noconfirm -
	$(YAY) - < ${HOME}/.config/pacman/temp2.txt

postinstall: sysoptions zsh emacs systemd hyprplugins wal

postreboot: firefox mpv mpd

# Targets to run manually:
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

# https://github.com/yokoffing/Betterfox
# https://github.com/MrOtherGuy/firefox-csshacks
# NOTE: firefox must be started (once) to create folder with default-profile
firefox: ## symlinks user.js and userChrome.css files to default firefox profile
	find ${HOME}/.mozilla/firefox/ -maxdepth 1 -type d -name '*.default-release' \
		-exec ln -s $(XDG_CONFIG_HOME)/firefox/user.js {}/user.js \;
	find ${HOME}/.mozilla/firefox/ -maxdepth 1 -type d -name '*.default-release' \
		-exec ln -s $(XDG_CONFIG_HOME)/firefox/chrome {}/chrome \;

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

hyprplugins:
	git clone 'git@github.com:VortexCoyote/hyprfocus.git' ${HOME}/utils/hyprfocus
	cd ${HOME}/utils/hyprfocus
	make all

# ------------  Other  ------------

systemd: ## enable and start all user and system systemd services
	$(SSEN) systemd-timesyncd.service
	$(SSEN) plocate-updatedb.service
	$(SSEN) bluetooth.service
# sequence of these 2 needs to be hardcoded sadly
	$(SUEN) eww.service
	$(SUEN) eww-window@topbar.service
	find ${HOME}/.config/systemd/user/ -type f -printf "%f\n" |
		xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service

# system files changed
sysoptions: ## make changes to system files
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
  # =/etc/bluetooth/main.conf= <- AutoEnable=false
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf
	sudo grub-mkconfig -o /boot/grub/grub.cfg
	sudo echo UserspaceHID=true | sudo tee -a /etc/bluetooth/input.conf

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

xiaomi: ## install stuff for nvidia hybrid laptop
	$(PACMAN) --needed intel-media-driver nvidia nvidia-prime nvtop nvidia-dkms \
		nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
	$(YAY) libva-nvidia-driver-git

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
