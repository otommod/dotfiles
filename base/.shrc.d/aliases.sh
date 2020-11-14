alias ls='ls --color=auto -Fh --group-directories-first'
alias l='ls'
alias la='ls -A'         # Lists human readable sizes, hidden files.
alias ll='ls -l'         # Lists human readable sizes.
alias lla='ll -A'        # Lists human readable sizes, hidden files.
alias lal='la -l'        # same
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.

# One alternative to the alias is the following function
# dash() {
#     if command -v rlwrap >/dev/null; then
#         rlwrap dash "$@"
#     else
#         dash "$@"
#     fi
# }
alias rldash='rlwrap dash'

#
# Rsync
#
# TODO: consider using rsync more
if command -v rsync >/dev/null; then
    _rsync_cmd='rsync --verbose --progress --human-readable --compress --archive --hard-links --one-file-system'

    if rsync --help 2>&1 | grep -q 'xattrs'; then
        _rsync_cmd="${_rsync_cmd} --acls --xattrs"
    fi

    # Mac OS X and HFS+ Enhancements
    # http://help.bombich.com/kb/overview/credits#opensource
    case "$OSTYPE" in
        darwin*)
            if rsync --help 2>&1 | grep -q 'file-flags'; then
                _rsync_cmd="${_rsync_cmd} --crtimes --fileflags --protect-decmpfs --force-change"
            fi
    esac

    alias rsync-copy="${_rsync_cmd}"
    alias rsync-move="${_rsync_cmd} --remove-source-files"
    alias rsync-update="${_rsync_cmd} --update"
    alias rsync-synchronize="${_rsync_cmd} --update --delete"
fi
