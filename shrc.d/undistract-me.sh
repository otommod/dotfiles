#!/bin/sh

__udm_notify() {
    if command -v terminal-notifier >/dev/null; then # macOS
        local term_id
        [ "$TERM_PROGRAM" = 'iTerm.app' ] && term_id='com.googlecode.iterm2'
        [ "$TERM_PROGRAM" = 'Apple_Terminal' ] && term_id='com.apple.terminal'

        if [ -z "$term_id" ]; then
            terminal-notifier -message "$2" -title "$1" >/dev/null
        else
            terminal-notifier -message "$2" -title "$1" \
                -activate "$term_id" -sender "$term_id" >/dev/null
        fi

    elif command -v growlnotify >/dev/null; then # macOS Growl
        growlnotify -m "$1" "$2"

    elif command -v notify-send >/dev/null; then # Linux
        notify-send "$1" "$2"

    elif command -v notifu >/dev/null; then # Cygwin
        notifu /m "$2" /p "$1"

    else # generic
        printf '\a'
    fi
}

__udm_active_wid() {
    if command -v osascript >/dev/null; then
        osascript -e 'tell application '                \
            '(path to frontmost application as text) '  \
            'to id of front window' 2>/dev/null || echo None

    elif command -v xprop >/dev/null && [ -n "$DISPLAY" ]; then
        local oldIFS="$IFS"; unset IFS
        local oldOpts="$(set +o)"; set -f
        set -- $(xprop -root _NET_ACTIVE_WINDOW)
        IFS="$oldIFS"; eval "$oldOpts"

        printf '%s\n' "$5"

    else
        echo None
    fi
}

__udm_humanize_time() {
    local d=$(( $1 / 60 / 60 / 24 )) \
          h=$(( $1 / 60 / 60 % 24 )) \
          m=$(( $1 / 60 % 60 ))      \
          s=$(( $1 % 60 ))
    [ $d -gt 0 ] && printf '%dd ' "$d"
    [ $h -gt 0 ] && printf '%dh ' "$h"
    [ $m -gt 0 ] && printf '%dm ' "$m"
    printf '%ds\n' "$s"
}

__udm_format() {
    ## args: (cmdname, cmd, exitstatus, elapsed)
    local cmdstatus="finished"
    [ "$3" -ne 0 ] && cmdstatus="failed with $3"

    local elapsed="$(__udm_humanize_time "$4")"
    if [ -z "$SSH_CONNECTION" ]; then
        __udm_notify "$1 $cmdstatus in $elapsed" "$2"
    else
        __udm_notify "$1 $cmdstatus on $(hostname) in $elapsed" "$2"
    fi
}

__udm_parse_cmdname() {
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


__udm_assign_cmd() {
    # If the command is in $UDM_IGNORE_LIST, do nothing.
    unset __udm_notify
    case "$UDM_IGNORE_LIST" in
        "$1"|"$1:"*|*":$1"|*":$1:"*) return ;;
    esac

    __udm_notify=true
    __udm_cmdname="$1"
    __udm_cmdline="$2"
}

__udm_preexec() {
    __udm_timestamp=$(date +'%s')
    __udm_wid=$(__udm_active_wid)

    __udm_parse_cmdname "$1" __udm_assign_cmd "$1"
}

__udm_precmd() {
    local exitstatus=$?

    [ -z "$__udm_notify" ] && return

    # if the command took less that $UDM_THRESHOLD to complete, do nothing
    local elapsed=$(( $(date +'%s') - __udm_timestamp ))
    [ $elapsed -le "${UDM_THRESHOLD:-10}" ] && return

    # if the current window is the one that started the command, do nothing
    local wid="$(__udm_active_wid)"
    [ "$wid" = None ] && return
    [ "$wid" = "$__udm_wid" ] && return

    __udm_format "$__udm_cmdname" "$__udm_cmd" "$exitstatus" "$elapsed"
}
