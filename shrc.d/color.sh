#!/bin/sh

if command -v dircolors >/dev/null 2>&1; then
    [ -r ~/.colors/dircolors ] && eval "$(dircolors -b ~/.colors/dircolors)"
fi
