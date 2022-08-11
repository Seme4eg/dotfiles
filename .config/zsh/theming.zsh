#!/usr/bin/env zsh

# Docs on theming: https://man.archlinux.org/man/zshcontrib.1#PROMPT_THEMES
# (also some info in arch wiki in zsh article)

autoload -Uz promptinit && promptinit
[[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] ||
zmodload zsh/nearcolor

# Copy icons: https://youtu.be/KBh8lM3jeeE?t=863

# Define the theme
prompt_sad_setup() {
  # Doc on prompt string: https://man.archlinux.org/man/zshmisc.1#Visual_effects
  # Colors here: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
  PROMPT='%B%F{183}%n%f@%F{087}%M %f| %1d/ ╭ರ_•́%b ' # left
  RPROMPT='[%F{183}%?%f] (⌣_⌣”)' # right
}

prompt_themes+=( sad ) # Add the theme to promptsys

# prompt sad # 'my' theme, but for now i use grmls' one

# set the default prompt to the walters theme
# prompt elite2 cyan white #magenta # 'prompt -l' - list awailable themes
