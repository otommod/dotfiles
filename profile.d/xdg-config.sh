#!/bin/sh

# The '~/.httpie' config dir is always created but it's not at all needed, so
# at least move if out of the way.
export HTTPIE_CONFIG_DIR=${XDG_CONFIG_HOME:-~/.config}/httpie

mkdir -p "$HTTPIE_CONFIG_DIR"
