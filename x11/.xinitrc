#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

mv ~/.xsession-errors ~/.xsession-errors.old
if command -v systemd-cat >/dev/null 2>&1; then
    # TODO: clean it up on exit
    mkfifo ~/.xsession-errors
    systemd-cat -t xinitrc <~/.xsession-errors &
fi
exec 2>~/.xsession-errors

[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

[ -f /etc/X11/Xresources ] && xrdb -merge /etc/X11/Xresources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

[ -f /etc/X11/Xkbmap ] && setxkbmap $(cat /etc/X11/Xkbmap)
[ -f ~/.Xkbmap ] && setxkbmap $(cat ~/.Xkbmap)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

exec i3
