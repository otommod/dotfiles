#!/bin/sh

tmppipe=/tmp/dwmstatus-fifo
if [ ! -p "$tmppipe" ]; then
    mkfifo -m 600 "$tmppipe"
fi

interval() {
    local n="$1"
    shift

    while true; do
        "$@"
        sleep "$n"
    done
}

meminfo() {
    local label value unit

    while read -r label value unit; do
        # XXX: make sure units are kB and label ends in a ':' (meaning that we
        # captured the whole label and it didn't 'leak' in $value or $unit)
        printf 'mem-%s %d\n' "${label%:}" "$value"
    done </proc/meminfo
}

bandwidth() {
    local iface=$1
    local interval=5
    local rx_old tx_old rx_now tx_now
    read -r rx_old <"/sys/class/net/$iface/statistics/rx_bytes"
    read -r tx_old <"/sys/class/net/$iface/statistics/tx_bytes"

    while true; do
        read -r rx_now <"/sys/class/net/$iface/statistics/rx_bytes"
        read -r tx_now <"/sys/class/net/$iface/statistics/tx_bytes"

        printf 'net-rx %4d\nnet-tx %3d\n' \
            $(( (rx_now - rx_old) / (interval * 1024) )) \
            $(( (tx_now - tx_old) / (interval * 1024) ))
        tx_old=$tx_now rx_old=$rx_now

        sleep $interval
    done
}

~/.config/dwm/mprisplaying.py >"$tmppipe" &

~/.config/dwm/pulsevol.py >"$tmppipe" &

interval 30 date +"clock %a %d %b %Y %H:%M" >"$tmppipe" &

interval 5 meminfo >"$tmppipe" &

bandwidth wlp4s6 >"$tmppipe" &

while read -r i text; do
    case "$i" in
        clock) clock="$text" ;;
        net-rx) rx="$text" ;;
        net-tx) tx="$text" ;;
        music-artist) artist="$text" ;;
        music-title) song="$text" ;;
        mem-MemAvailable) MemAvailable="$text" ;;
        mem-MemTotal) MemTotal="$text" ;;
        vol) volume="$text" ;;
        *) continue ;;
    esac

    # emulate '%4d' without any command substitution
    # pad RX to 4 chars because I hate the status length jumping around
    case "$rx" in
        ???) rx=" $rx" ;;
        ??) rx="  $rx" ;;
        ?) rx="   $rx" ;;
    esac

    # similarly, pad TX to 3 chars
    case "$tx" in
        ??) tx=" $tx" ;;
        ?) tx="  $tx" ;;
    esac

    # red=$'\x02'
    # green=$'\x03'
    # yellow=$'\x04'

    mempercent=0
    if [ -n "$MemAvailable" ] && [ "$MemAvailable" -gt 0 ]; then
        mempercent=$(( 100 - 100 * MemAvailable  / MemTotal ))
    fi

    status=" ${artist:+$artist - }${song:+$song | }mem $mempercent% | down $rx up $tx | vol $volume | $clock"

    # Only update if something's changed
    if [ "$status" != "$old_status" ]; then
        xsetroot -name "$status"
    fi
    old_status="$status"
done <"$tmppipe"
