alias ls='ls --color=auto -Fh --group-directories-first'
alias l='ls'
# alias l='ls -1A'         # Lists in one column, hidden files.
alias la='ls -A'         # Lists human readable sizes, hidden files.
alias ll='ls -l'         # Lists human readable sizes.
alias lla='ll -A'        # Lists human readable sizes, hidden files.
alias lal='la -l'        # same
alias lr='ll -R'         # Lists human readable sizes, recursively.
alias lm='la | "$PAGER"' # Lists human readable sizes, hidden files through pager.
alias lx='ll -XB'        # Lists sorted by extension (GNU only).
alias lk='ll -Sr'        # Lists sorted by size, largest last.
alias lt='ll -tr'        # Lists sorted by date, most recent last.
alias lc='lt -c'         # Lists sorted by date, most recent last, shows change time.
alias lu='lt -u'         # Lists sorted by date, most recent last, shows access time.

# alias anime="mpv --msg-module --lua-opts=anime-mode=yes"
alias anime-todo='todo.sh -d "/home/otto/.todo/anime.conf"'

alias suspend='systemctl suspend; exit'

# The "ternary operator", as normally written in shell,
#       cond && if-expr || else-expr
# has not the exact semantics as its C counterpart: if the if-expr returns
# non-zero then else-expr will also be executed.
#
# If that where to happen to our alias, that is, if rlwrap exists and dash
# exits with a non-zero code it would be executed again!  The sollution is
# simple, just use a fullblown if.
alias dash='if command -v rlwrap >/dev/null; then rlwrap dash; else dash; fi'


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
