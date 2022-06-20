#!/bin/sh
# vim:fdm=marker:
#
# ~/.profile
#

for f in ~/.profile.d/*.sh; do
    # shellcheck source=/dev/null
    [ -x "$f" ] && . "$f"
done
unset f

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

# XXX: by default python uses ~/.local/bin so this is probably not needed
# if command -v python3 >/dev/null && \
#     prependpath "$(python3 -m site --user-base)/bin"

command -v go >/dev/null && \
    prependpath "${GOPATH:-$HOME/go}/bin"

export PATH
unset prependpath

# {{{1 Default programs
export PAGER=less
export EDITOR=nvim
export BROWSER=firefox

# {{{1 Settings
# Set the default `less` options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Let `man` use real italics.
# See https://jdebp.uk/Softwares/nosh/italics-in-manuals.html#Debian
export GROFF_SGR=yes
export MANROFFOPT='-- -P -i'

# {{{1 XDG_CONFIG_HOME
# IPython
export IPYTHONDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ipython"

# The python interpreter runs $PYTHONSTARTUP when started in interactive mode.
# We can use this to set the history file to $PYTHONHISTORY.  It mostly works;
# the -i flag suppresses running $PYTHONSTARTUP. See also the `site` module,
# responsible for readline support since python 3.4.  It will try importing a
# `usercustomize` module; can be used for customization but it needs to be in
# the python path which is different between versions and systems.
export PYTHONSTARTUP="${XDG_CONFIG_HOME:-$HOME/.config}/pythonrc"

# ripgrep will read its config file only if this variable is defined
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgreprc"

# {{{1 History
export HISTDIR="$HOME/.hist"
mkdir -p "$HISTDIR"

# Where the `rlwrap` utility writes its history
export RLWRAP_HOME="$HISTDIR/rlwrap"
mkdir -p "$RLWRAP_HOME"

# The `less` pager
export LESSHISTFILE="$HISTDIR/less"

# SQLite
export SQLITE_HISTORY="$HISTDIR/sqlite"

# nodeJS
export NODE_REPL_HISTORY="$HISTDIR/node"

# See $PYTHONSTARTUP
export PYTHON_REPL_HISTORY="$HISTDIR/python"

# `tig` uses ~/.tig_history unless the $XDG_DATA_HOME/tig directory exists.
# There's no way to move it anywhere else so at least hide it there.
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/tig"
