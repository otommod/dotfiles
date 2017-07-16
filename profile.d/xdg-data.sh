#!/bin/sh

# pylint data files
export PYLINTHOME=${XDG_DATA_HOME:-~/.local/share}/pylint.d

mkdir -p "$PYLINTHOME"
