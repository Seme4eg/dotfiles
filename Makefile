# run this file with 'sudo -E' to preserve env vars (ie. pwd)
# also there is this var
# .EXPORT_ALL_VARIABLES:

# If you prefer to prefix your recipes with a character other than tab, you
# can set the '.RECIPEPREFIX' variable to an alternate character (*note
# Special Variables::).

PACMAN := sudo pacman -S --noconfirm
YAY    := yay -S --noconfirm
SSEN   := sudo systemctl --now enable

.DEFAULT_GOAL := help

# prevents 'make' from getting confused by an actual file called 'allinstall',
# etc.. and causes it to continue in spite of errors
# .PHONY: all allinstall nextinstall allupdate allbackup

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test:
	@echo $(PWD)

# gnupg rootconfs
all: init ssh install systemd systemd-user

# XXX
# syncthing: ## Init syncthiing
# 	$(PACMAN) $@
# 	chmod 600 ${PWD}/.config/rclone/rclone.conf
# 	test -L ${HOME}/.config/rclone || rm -rf ${HOME}/.config/rclone
# 	ln -vsfn ${PWD}/.config/rclone ${HOME}/.config/rclone

gnupg: ## Deploy gnupg
	$(PACMAN) $@
	mkdir -p ${HOME}/.$@

# generate new ssh every time
ssh: ## Init ssh
	$(PACMAN) open$@
	mkdir -p ${HOME}/.$@
	ssh-keygen -t ed25519 -C "418@duck.com" -P ""
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_ed25519
	chmod 600 ${HOME}/.$@/id_ed25519

init: ## Initial deploy dotfiles
	mkdir -p ${HOME}/.local/share/applications
	mkdir -p ${HOME}/.local/share/fonts
	mkdir -p ${HOME}/.local/bin
	$(PACMAN) git stow
	stow .

${HOME}/utils/yay:
	mkdir -p ${HOME}/utils/yay

yay: ${HOME}/utils/yay
	git clone https://aur.archlinux.org/yay.git $<
	cd $< && makepkg -si --noconfirm
	yay --version

pacman:
  # add =Include = /home/earthian/.config/pacman/pacman.conf= to [options] section
  # in /etc/pacman.conf
  # Uncomment =[multilib]= section in =/etc/pacman.conf=

reflector:
	$(PACMAN) reflector
	$(SSEN) reflector
	sudo pacman -Syy

PACMAN_DIR := ${XDG_CONFIG_HOME/pacman}
install: yay pacman reflector ## Install all packages
	cp $(PACMAN_DIR)/pkglist.txt $(PACMAN_DIR)/temp1.txt
	cp $(PACMAN_DIR)/foreignpkglist.txt $(PACMAN_DIR)/temp2.txt
  # install yay or pacman packages first (possible pkg conflicts)?
	$(YAY) - < ~/.config/pacman/temp2.txt
	$(PACMAN) - < ~/.config/pacman/temp1.txt

systemd:
	$(SSEN) systemd-timesyncd.service
	$(SSEN) plocate-updatedb.service
	$(SSEN) bluetooth.service

systemd-user:
  # enable systemd user services with
	find $(XDG_CONFIG_HOME)/systemd/user/ -type f -printf "%f\n" | xargs -I {} systemctl --user enable --now {}
	systemctl --user --now enable syncthing.service
	systemctl --user --now enable udiskie.service
	systemctl --user --now enable mpd.service

# system files changed
rootconfs:
  # =/etc/systemd/journald.conf= <- SystemMaxUse=50M
  # =/etc/bluetooth/main.conf= <- AutoEnable=false
