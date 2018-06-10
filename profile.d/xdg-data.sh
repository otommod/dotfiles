#!/bin/sh

# pylint data files
export PYLINTHOME=${XDG_DATA_HOME:-"$HOME/.local/share"}/pylint

mkdir -p "$PYLINTHOME"
