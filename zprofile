#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

[[ -f ~/.profile ]] && source ~/.profile

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#     $cdpath
# )

# In macOS, TMPDIR is a per-user temp folder
if [[ ! -d "$TMPDIR" ]]; then
    export TMPDIR="$(mktemp -d)"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
