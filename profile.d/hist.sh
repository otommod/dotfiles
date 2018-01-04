#!/bin/sh

export HISTDIR=~/.hist
mkdir -p "$HISTDIR"

# Where the 'rlwrap' utility writes its history
export RLWRAP_HOME="$HISTDIR/rlwrap"
mkdir -p "$RLWRAP_HOME"

# For the 'less' pager
export LESSHISTFILE="$HISTDIR/less"

# The python interpreter runs $PYTHONSTARTUP at the, well, startup in
# interactive mode.  It's there that we set the history file to $PYTHONHISTORY,
# it's can't be done any other way.  This is not a complete solution: if python
# is run with the -i flag, $PYTHONSTARTUP is not run but 'import site' is,
# which is what loads readline and the history (only in python 3.4 and later).
# One could write a 'usercustomize' module, however you'd need to place it
# somewhere in the python path which is different between versions and systems.
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONHISTORY="$HISTDIR/python"
