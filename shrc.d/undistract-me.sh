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

    __parse_cmdname "$1" __udm_assign_cmd "$1"
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
