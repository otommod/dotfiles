__parse_cmdname() {
    local cmd="$1"; shift
    local callback="$2"; shift
    local callback_args="$#"

    # We split the command on spaces; this is *not* correct since it doesn't
    # take quoting into account but for display purposes it's fine.
    local oldIFS="$IFS"; unset IFS
    local oldOpts="$(set +o)"; set -f
    set -- $cmd "$@"
    IFS="$oldIFS"; eval "$oldOpts"

    while [ $# -gt $(( 1 + callback_args )) ]; do
        case "$1" in
            # skip some shell syntax
            #*=*) shift ;;
            \;|\&|\|) shift ;;
            \!|\&\&|\|\|) shift ;;
            \{|\}|\(|\)) shift ;;

            # skip some commands that take other commands
            exec) shift ;;
            ssh|*/ssh) shift ;;
            sudo|*/sudo) shift ;;

            # POSIX says: If the -p option is specified, the output shall
            # consist of one line for each process ID:
            #
            #     "%d\n", <process ID>
            #
            # Obviously, some shells (like zsh, even in emulate sh) don't
            # follow the spec like that, it'd be too easy. Moreover, to read
            # those PIDs you'd need to use either command substitution or pipes
            # and these spawn subshells.  For most shells these subshells don't
            # share the jobs of their parent shell.  You'd need to use
            # temporary files or things like process substitution and by that
            # point you're either too xomplex or non-portable.
            #
            # If you could get the PID though, getting the command name is
            # POSIXly easy, it's just:
            #
            #    ps -p $pid -o comm=
            #
            # XXX: In order to successfully find the job you would need to call
            # this function while the job is still running.  For hooks that
            # would mean preexec and not precmd; the latter fires too late.
            fg|%*) break ;;

            *) break ;;
        esac
    done
    cmd="$(basename "$1")"
    shift "$(( $# - callback_args ))"

    if command -v "$callback" >/dev/null; then
        "$callback" "$cmd" "$@"
    fi
}
