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
# some comment here
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
	chmod 700 ~/.gnupg
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
	mkdir ${HOME}/git
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
install: reflector yay pacman ## Install all packages
	if [ ! -f $(PACMAN_DIR)/temp1.txt ]; then
		cp $(PACMAN_DIR)/pkglist.txt $(PACMAN_DIR)/temp1.txt
		cp $(PACMAN_DIR)/foreignpkglist.txt $(PACMAN_DIR)/temp2.txt
	fi
	sudo pacman -Syy
	$(PACMAN) - < ~/.config/pacman/temp1.txt
	$(YAY) - < ~/.config/pacman/temp2.txt

postinstall: sysoptions zsh systemd emacs pass mail firefox mpv mpd waydroid


# ------------  Packages  ------------

zsh:
	chsh -s /usr/bin/zsh

systemd:
	$(SSEN) systemd-timesyncd.service
	$(SSEN) plocate-updatedb.service
	$(SSEN) bluetooth.service
	find $(XDG_CONFIG_HOME)/systemd/user/ -type f -printf "%f\n" | xargs -I {} systemctl --user enable --now {}
	$(SUEN) syncthing.service
	$(SUEN) udiskie.service
	$(SUEN) mpd.service

emacs: 
	git clone --depth 1 --single-branch https://github.com/doomemacs/doomemacs ~/.config/$@
	~/.config/$@/bin/doom install
	doom sync
	rm -rf ${HOME}/.$@.d

pass:
	git clone git@github.com:Seme4eg/pass.git $(XDG_DATA_HOME)/password-store
# FIXME: emacs doesn't know about =$PASSWORD_STORE_DIR= env var
	ln -s $(XDG_DATA_HOME)/password-store ${HOME}/.password-store

# Make sure gpg is set up.
# If any problems refer to mu4e documentation of doom emacs.
# Just don't install mu-git, it's broken atm.
mail: pass ## install, sync and index mail with mu and mbsync
	mkdir -p ${HOME}/.$@/mailru
	mkdir -p ${HOME}/.$@/zimbra
	mbsync --all
	sh ${HOME}/secrets/index
	mu index

# https://github.com/yokoffing/Betterfox
# https://github.com/MrOtherGuy/firefox-csshacks
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

# TODO: need better testing
waydroid:
	sudo waydroid init
	wget -P ${HOME}/Downloads https://dl.anixart.tv/anixart.apk
	$@ session start
	$@ app install ${HOME}/Downloads/anixart.apk
	@echo 'Now you need a reboot'

# ------------  Other  ------------

# system files changed
sysoptions:
	sudo sed -i 's/^#\(SystemMaxUse\)=.*/\1=50M/' /etc/systemd/journald.conf
  # =/etc/bluetooth/main.conf= <- AutoEnable=false
	sudo sed -i 's/^#\(HandlePowerKey\)=.*/\1=suspend/' /etc/systemd/logind.conf
	sudo sed -i 's/^#\(HandleLidSwitch\)=.*/\1=ignore/' /etc/systemd/logind.conf

# useful when removed some file(s) from repo and don't want to remove the
# symlinks by hand
clean: ## removes all broken symlinks recursively
	cd ${HOME}
	find . -path ./.local/share -prune -o -path ./.cache -prune -o -xtype l -print |
		xargs rm
