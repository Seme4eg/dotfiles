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
	sudo pacman -Syy
	$(PACMAN) - < ${HOME}/.config/pacman/temp1.txt
	$(YAY) - < ${HOME}/.config/pacman/temp2.txt

postinstall: sysoptions zsh npm emacs systemd wal icons

# waydroid - debug
# protonge <- run only after steam launch cuz steam creates symlink to root dir
postreboot: firefox mpv mpd


# ------------  Packages  ------------

zsh:
	chsh -s /usr/bin/zsh

npm: ## needed for 'doom env' and lsp installation
	nvm install 18.16

wal: ## for hyprland to not show error of undefined color var on first launch
	wal -n -q -i "${HOME}/.config/hypr/assets/default-wp.jpg" --saturate 0.3

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
# to get newer command run ':nativeinstall' in browser
	curl -fsSl https://raw.githubusercontent.com/tridactyl/native_messenger/master/installers/install.sh \
		-o /tmp/trinativeinstall.sh && sh /tmp/trinativeinstall.sh 1.23.0

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

# TODO: need better testing
waydroid:
	sudo waydroid init
	wget -P ${HOME}/Downloads https://dl.anixart.tv/anixart.apk
	$@ session start
	$@ app install ${HOME}/Downloads/anixart.apk
	@echo 'Now you need a reboot'

# ------------  Other  ------------

systemd:
	$(SSEN) systemd-timesyncd.service
	$(SSEN) plocate-updatedb.service
	$(SSEN) bluetooth.service
	find $(XDG_CONFIG_HOME)/systemd/user/ -type f -printf "%f\n" |
		xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service

# system files changed
sysoptions:
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
  # =/etc/bluetooth/main.conf= <- AutoEnable=false
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf
	sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT=.*\)"/\1 nvidia_drm.modeset=1"/' \
		/etc/default/grub
	sudo grub-mkconfig -o /boot/grub/grub.cfg
	sudo echo UserspaceHID=true | sudo tee -a /etc/bluetooth/input.conf

icons:
	bash ${HOME}/.icons/unpack-all
	nwg-look -a

protonge:
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
