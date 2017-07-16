#!/bin/sh

[ ! -d ~/.dotfiles ] && die "No ~/.dotfiles directory"
RCRC=~/.dotfiles/rcrc rcup
