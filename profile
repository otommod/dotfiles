#!/bin/sh

if [ -d ~/.profile.d ]; then
    for f in ~/.profile.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi
