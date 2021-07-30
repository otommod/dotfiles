#!/bin/sh

case "$TERM" in
    st|stterm|st-*|stterm-*) export COLORTERM=truecolor ;;
esac

if command -v dircolors >/dev/null 2>&1; then
    [ -r ~/.colors/dircolors ] && eval "$(dircolors -b ~/.colors/dircolors)"
fi
