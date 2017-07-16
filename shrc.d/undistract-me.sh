#!/bin/sh

__udm_notify() {
    if command -v terminal-notifier >/dev/null; then # OS X
        [ "$TERM_PROGRAM" = 'iTerm.app' ] && term_id='com.googlecode.iterm2'
        [ "$TERM_PROGRAM" = 'Apple_Terminal' ] && term_id='com.apple.terminal'

        if [ -z "$term_id" ]; then
            terminal-notifier -message "$2" -title "$1" >/dev/null
        else
            terminal-notifier -message "$2" -title "$1" \
                -activate "$term_id" -sender "$term_id" >/dev/null
        fi

    elif command -v growlnotify >/dev/null; then # OS X Growl
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
    local oldIFS oldOpts

    if command -v osascript >/dev/null; then
        osascript -e 'tell application '                \
            '(path to frontmost application as text) '  \
            'to id of front window' 2>/dev/null || echo None

    elif command -v xprop >/dev/null && [ -n "$DISPLAY" ]; then
        oldIFS=IFS; unset IFS
        oldOpts=$(set +o); set -f
        set -- $(xprop -root _NET_ACTIVE_WINDOW)
        IFS=$oldIFS; eval "$oldOpts"

        printf '%s\n' "$5"

    else
        echo None
    fi
}

__udm_parse_cmdname() {
    # This is *NOT* correct, but it doesn't matter for our use case
    basename "${1%%[[:space:]]*}"
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


__udm_preexec() {
    __udm_cmd="$1"
    __udm_timestamp=$(date +'%s')
    __udm_wid=$(__udm_active_wid)
}

__udm_precmd() {
    local exitstatus=$?

    # if the command took less that UDM_THRESHOLD to complete, do nothing
    [ -z "$__udm_timestamp" ] && return
    local elapsed=$(( $(date +'%s') - __udm_timestamp ))
    [ $elapsed -le "${UDM_THRESHOLD:=10}" ] && return

    # if the current window is the one that started the command, do nothing
    local wid="$(__udm_active_wid)"
    [ "$wid" = None ] && return
    [ "$wid" = "$__udm_wid" ] && return

    # if the command is in the UDM_IGNORE_LIST, do nothing
    local cmdname="$(__udm_parse_cmdname "$__udm_cmd")"
    if [ "$cmdname" = sudo ] || [ "$cmdname" = ssh ]; then
        cmdname="${__udm_cmd#"$cmdname"}"
        cmdname="$(__udm_parse_cmdname "$cmdname")"
    fi
    case "$UDM_IGNORE_LIST" in
        "$cmdname"|"$cmdname:"*|*":$cmdname"|*":$cmdname:"*) return ;;
    esac

    __udm_format "$cmdname" "$__udm_cmd" "$exitstatus" "$elapsed"
    unset __udm_timestamp
}
