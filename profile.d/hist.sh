#!/bin/sh

export HISTDIR=~/.hist
mkdir -p "$HISTDIR"

# Where the 'rlwrap' utility writes its history
export RLWRAP_HOME="$HISTDIR/rlwrap"
mkdir -p "$RLWRAP_HOME"

# For the 'less' pager
export LESSHISTFILE="$HISTDIR/less"
