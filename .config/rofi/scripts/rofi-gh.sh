#!/usr/bin/env bash

# author:    Miroslav Vidovic
# created:   04.04.2017.-09:18:34

USER="seme4eg"

clone_repository(){
  if [ ! -z "$1" ]; then
    notify-send -a $(whoami) "Cloning $1 ..."
    cd ~/git
    git clone "$1"
    notify-send -a $(whoami) "Cloned $1"
  fi
}

# Get all the repositories for the user with curl and GitHub API and filter only
# the repository name from the output with sed substitution
all_my_repositories_short_name(){
  curl -s "https://api.github.com/users/$USER/repos?per_page=1000" |
    grep -o 'git@[^"]*' |
    sed "s/git@github.com:$USER\///g"
}

rofi_dmenu(){
  rofi -dmenu -matching fuzzy -no-custom -p "Select a repository > "\
    -location 0 -bg "#F8F8FF" -fg "#000000" -hlbg "#ECECEC" -hlfg "#0366d6"
}

repository=$(all_my_repositories_short_name | rofi_dmenu )

clone_repository "$repository"
