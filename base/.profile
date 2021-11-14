#!/bin/sh
# vim:fdm=marker:
#
# ~/.profile
#

if [ -d ~/.profile.d ]; then
    for f in ~/.profile.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi


# {{{1 Golang
# Use Go modules; I'm not sure if this is needed after Go 1.13
export GOPATH="$HOME/go"
export GO111MODULE=on


# {{{1 PATH
# Taken mostly from Arch Linux's /etc/profile
prependpath() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

prependpath "$HOME/bin"
prependpath "$HOME/.local/bin"

command -v go >/dev/null && \
    prependpath "${GOPATH:-$HOME/go}/bin"


# XXX: by default python uses ~/.local/bin, so dunno if this is needed
# if command -v python3 >/dev/null; then
#     python3 -c 'import sys, site; sys.stdout.write(site.USER_BASE + "/bin")'
# or just
#     "$(python3 -m site --user-base)/bin"
# fi

export PATH
unset prependpath


# {{{1 Default programs
export PAGER=less

export EDITOR=nvim

export TERMINAL=st

export BROWSER=firefox

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'


# {{{1 History
export HISTDIR="$HOME/.hist"
mkdir -p "$HISTDIR"

# Where the 'rlwrap' utility writes its history
export RLWRAP_HOME="$HISTDIR/rlwrap"
mkdir -p "$RLWRAP_HOME"

# For the 'less' pager
export LESSHISTFILE="$HISTDIR/less"

# SQLite
export SQLITE_HISTORY="$HISTDIR/sqlite"

# nodeJS
export NODE_REPL_HISTORY="$HISTDIR/node"

# The python interpreter runs $PYTHONSTARTUP at the, well, startup in
# interactive mode.  It's there that we set the history file to $PYTHONHISTORY,
# it's can't be done any other way.  This is not a complete solution: if python
# is run with the -i flag, $PYTHONSTARTUP is not run but 'import site' is,
# which is what loads readline and the history (only in python 3.4 and later).
# One could write a 'usercustomize' module, however you'd need to place it
# somewhere in the python path which is different between versions and systems.
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONHISTORY="$HISTDIR/python"

# 'tig' will write to ~/.tig_history unless ~/.local/share/tig exists and is a
# directory.  There doesn't seem to be a way to write it where I want so at
# least put it out of the way.
mkdir -p ~/.local/share/tig


# {{{1 XDG_CONFIG_HOME
# The logs, at least, the channel logs, can be set to go to $HISTDIR with
#     /set logger.file.path "${env:HISTDIR}/weechat"
# The program logs always go to $WEECHAT_HOME/weechat.log.
export WEECHAT_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}/weechat
mkdir -p "$WEECHAT_HOME"

# IPython
export IPYTHONDIR=${XDG_CONFIG_HOME:-"$HOME/.config"}/ipython
mkdir -p "$IPYTHONDIR"

# ripgrep will read it's config file only if this variable is defined
export RIPGREP_CONFIG_PATH=${XDG_CONFIG_HOME:-"$HOME/.config"}/ripgreprc


# {{{1 XDG_DATA_HOME
# pylint data files
export PYLINTHOME=${XDG_DATA_HOME:-"$HOME/.local/share"}/pylint
mkdir -p "$PYLINTHOME"


# {{{1 Game saves
export SAVESDIR=~/.saves
