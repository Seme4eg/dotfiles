#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# PS1='[\u@\h \W]\$ '

# --------- clean everything below

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
# xterm-color|*-256color) color_prompt=yes;;
# esac

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export EDITOR='emacs-nw'

# Alias definitions are defined in file below
# if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases fi

# remotely create git branch and optionally push in
# contents of current path
function do_rep() {
  # make this function shorter in future by making it use flags instead
  # of 'read'

  # check the if below for a better one! you know how
  # or if -- help is given
  if [[ $1 = '' ]]; then
    echo 'do_rep {rep_name}'
    return
  fi

  read -p 'private rep? [y/n] '

  if [[ $REPLY = y ]]; then
    curl -u Seme4eg https://api.github.com/user/repos -d \
      "{\"name\": \"$1\", \"private\": \"true\"}"
  else
    curl -u Seme4eg https://api.github.com/user/repos -d \
      "{\"name\": \"$1\"}"
  fi

  read -p 'init git here? [y/n] '

  if [[ $REPLY = y ]]; then
    git init

    read -p 'push content of cur folder to created rep? [y/n] '

    if [[ $REPLY = y ]]; then
      git add .
      git commit -m 'initial commit'
      # here if name of rep is 'C++' an error occures
      git remote add origin git@github.com:Seme4eg/$1.git
      git push origin master
    fi
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
