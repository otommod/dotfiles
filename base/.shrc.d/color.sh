#!/bin/sh

case "$TERM" in
    st|stterm|st-*|stterm-*) export COLORTERM=truecolor ;;
esac

if command -v dircolors >/dev/null 2>&1; then
    # XXX: env TERM=xterm-256color is a fix for foot
    # https://codeberg.org/dnkl/foot/wiki#no-colors-in-ls-output
    [ -r ~/.colors/dircolors ] && eval "$(env TERM=xterm-256color dircolors -b ~/.colors/dircolors)"
fi
