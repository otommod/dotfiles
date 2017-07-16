#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

[ -f ~/.xsession-errors ] && mv ~/.xsession-errors ~/.xsession-errors.old
exec 2>~/.xsession-errors

[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

exec awesome
