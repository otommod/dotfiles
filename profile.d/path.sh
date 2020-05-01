#!/bin/sh

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
