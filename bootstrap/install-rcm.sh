#!/bin/sh

VERSION="1.2.3"
URL="https://thoughtbot.github.io/rcm"

TARBALL="rcm-${VERSION}.tar.gz"
SHA256SUM="502fd44e567ed0cfd00fb89ccc257dac8d6eb5d003f121299b5294c01665973f"

: ${BINDIR:=~/bin}
: ${XDG_DATA_HOME:=~/.local/share}


die() { echo "$1" >&2; exit "${2:-1}"; }
has() { command -v "$1" >/dev/null; }

download() {
    if   has curl; then curl -LO# "$1"
    elif has wget; then wget -nv --show-progress "$1"

    else die "No 'wget' nor 'curl' in \$PATH"; fi
}

sha256() {
    if has sha256sum; then sha256sum "$1" | cut -f1 -d' '

    else die "No 'sha256sum' in \$PATH"; fi
}

die "this script is deprecated, please install rcm in another way"

cd "$(mktemp -dt rcm.XXXXXX)"                                       \
                                                                    \
    && download "https://thoughtbot.github.io/rcm/dist/${TARBALL}"  \
    && [ "$(sha256 "$TARBALL")" = "$SHA256SUM" ]                    \
                                                                    \
    && tar xf "${TARBALL}"                                          \
    && cd "rcm-${VERSION}"                                          \
                                                                    \
    && ./configure --bindir="$BINDIR" --datarootdir="$PWD"          \
    && make                                                         \
    && make install
