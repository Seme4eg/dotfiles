#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then xrdb -merge $sysresources; fi
if [ -f $sysmodmap ]; then xmodmap $sysmodmap; fi
if [ -f "$userresources" ]; then xrdb -merge "$userresources"; fi
if [ -f "$usermodmap" ]; then xmodmap "$usermodmap"; fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# twm &
# xclock -geometry 50x50-1+1 &
# xterm -geometry 80x50+494+51 &
# xterm -geometry 80x20+494-0 &
# exec xterm -geometry 80x66+0+0 -name login

# custom settings
setxkbmap -layout "us,ru" -option "ctrl:swapcaps" # reverse swap `setxkbmap -option`
# setxkbmap dvorak # eh?)
# xmodmap ~/.Xmodmap
# xrdb -merge ~/.Xresources
xset r rate 210 42
xinput set-prop 12 359 1                          # set tap to click for touchbar
xinput set-prop 12 338 1                          # enable natural scrolling

# string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd)
nitrogen --set-zoom-fill --random ~/Pictures/atmosphere/Wadim Kashin &
unclutter -root &
nm-applet &
picom --experimental-backends &
blueman-applet &
redshift -l 55.75222:37.61556 -t 6500:4000 &
emacs &
qutebrowser &
org.telegram.desktop &
com.discordapp.Discord &
xss-lock -- slock &                               # Enable screen locking on suspend

# Switching between DEs / WMs usint xinit:
# https://wiki.archlinux.org/title/Xinit#Switching_between_desktop_environments/window_managers

exec awesome
