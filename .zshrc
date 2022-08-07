# https://wiki.archlinux.org/title/Zsh
# https://zsh.sourceforge.io/Guide/zshguide02.html
# Creating widgets (commands/aliases):
# https://sgeb.io/posts/zsh-zle-custom-widgets/
# Zsh documentation: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
# Part of code below was taken from here:
# https://github.com/LukeSmithxyz/voidrice/blob/master/.config/zsh/.zshrc
# Zsh loadable modules: https://man.archlinux.org/man/zshmodules.1#THE_ZSH/NEARCOLOR_MODULE

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.cache/zsh/history
HISTSIZE=10000
SAVEHIST=10000
setopt autocd extendedglob nomatch notify interactive_comments
stty stop undef # disable C-s to freeze terminal
unsetopt beep

# Load aliases and shortcuts if existent.
[ -f "~/.config/shell/shortcutrc" ] && source "~/.config/shell/shortcutrc"
[ -f "~/.config/shell/aliasrc" ] && source "~/.config/shell/aliasrc"
[ -f "~/.config/shell/zshnameddirrc" ] && source "~/.config/shell/zshnameddirrc"

###############################################################################
#                                Completioning                                #
###############################################################################

autoload -Uz compinit && compinit
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix suffix
# zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._- ]=** r:|=** l:|=*'
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original false
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/essence/.zshrc'

# For enabling autocompletion of privileged environments in privileged commands
zstyle ':completion::complete:*' gain-privileges 1

###############################################################################
#                                   Theming                                   #
###############################################################################

# Docs on theming: https://man.archlinux.org/man/zshcontrib.1#PROMPT_THEMES
# (also some info in arch wiki in zsh article)

autoload -Uz promptinit && promptinit
[[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] ||
zmodload zsh/nearcolor

# Define the theme
prompt_sad_setup() {
  # Doc on prompt string: https://man.archlinux.org/man/zshmisc.1#Visual_effects
  # Colors here: https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
  PROMPT='%B%F{183}%n%f@%F{087}%M %f| %1d/ ╭ರ_•́%b ' # left
  RPROMPT='[%F{183}%?%f] (⌣_⌣”)' # right
}

prompt_themes+=( sad ) # Add the theme to promptsys

prompt sad # 'my' theme

# set the default prompt to the walters theme
# prompt elite2 cyan white #magenta # 'prompt -l' - list awailable themes

###############################################################################
#                                history search                               #
###############################################################################

# enable history search (bound to C-k & C-j)

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -s '^p' up-line-or-beginning-search
bindkey -s '^n' down-line-or-beginning-search

###############################################################################
#                                   vi mode                                   #
###############################################################################

bindkey -v
# export KEYTIMEOUT=1 # why?

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}

zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init

echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

###############################################################################
#                                   Utility                                   #
###############################################################################

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

bindkey -s '^o' '^ulfcd\n'
bindkey -s '^a' '^ubc -lq\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
bindkey '^[[P' delete-char

###############################################################################
#                              Last things to do                              #
###############################################################################

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
