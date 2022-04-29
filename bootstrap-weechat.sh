#!/bin/sh

run_weechat_commands() {
    while read -r line; do
        set -- "$@" -r "$line"
    done

  weechat -a "$@" -r '/quit' </dev/tty
}

escape_semicolons() {
    sed -e 's/;/\\;/g'
}

expand_keepass() {
    keepass_args=$1
    keepass_args=${keepass_args#'(keepass '}
    keepass_args=${keepass_args%')'}

    set -f
    IFS=' 	'  # a space and a tab

    # `$keepass_args` should contain two space-separated arguments; the
    # attribute and the entry name
    # shellcheck disable=SC2016,SC2086
    keepassxc-cli show "$keepass_db" -sa $keepass_args </dev/tty |
        sed -e 's/\$/${raw:$}/g'
}

expand_or_escape_dollars() {
    while IFS= read -r line; do
        IFS=\$
        set -f
        set -- $line''

        # $keepass_db not given; skip lines that contain $(keepass ...)
        if [ -z "$keepass_db" ]; then
            # the first argument does not have a dollar sign preceding it
            has_dollar=false
            for part; do
                if $has_dollar; then
                    case "$part" in
                        '(keepass '*) continue 2
                    esac
                fi
                has_dollar=true
            done
        fi

        printf '%s' "$1"
        shift

        for part; do
            case "$part" in
                '(keepass '*)
                    trailing=${part#(*)}
                    expand_keepass "${part%"$trailing"}"
                    printf '%s' "$trailing"
                ;;

                'eval:'*) printf '$%s' "${part#'eval:'}" ;;
                *) printf '${raw:$}%s' "$part" ;;
            esac
        done
        printf '\n'
    done
}

import_weechat() {
    # filter out empty lines and comments (lines starting with a '#')
    grep -v -e '^[ \t]*$' -e '^[ \t]*#' |
        expand_or_escape_dollars |
        escape_semicolons |
        run_weechat_commands
}

usage() {
    printf 'usage: %s -h\n' "$0"
    printf '       %s [-k KEEPASS_DB]\n' "$0"
    exit "${1-0}"
}

while getopts 'hk:' flag; do
    case "$flag" in
        k) keepass_db="$OPTARG" ;;
        h) usage ;;
        *) usage 1 ;;
    esac
done

# TODO: change `irc.default_server.username` and `irc.default_server.nicks`
# TODO: try using `keepasxc-proxy` to avoid typing my password 6 separate times
# TODO: try using `keepasxc-proxy` somehow as WEECHAT_PASSPHRASE
# TODO: try using `keepasxc-proxy` to get the credentials directly and skip the
#       weechat secure storage alltogether
# also see: https://gist.github.com/pascalpoitras/8406501
import_weechat <<'EOF'
/mouse enable
/set irc.look.server_buffer independent
/set irc.look.new_pv_position near_server
/set irc.look.new_channel_position near_server

/set weechat.plugin.autoload "*,!ruby,!tcl,!guile,!perl,!lua,!spell"

/set logger.level.irc 3
/set logger.file.path ${env:HISTDIR}/weechat

/secure passphrase $(keepass password Weechat)
/secure set libera_pass $(keepass password irc.libera.chat)
/secure set libera_user $(keepass username irc.libera.chat)
/secure set libera_nicks $(keepass nicknames irc.libera.chat)
/secure set oftc_pass $(keepass password irc.oftc.net)
/secure set oftc_nicks $(keepass nicknames irc.oftc.net)

/server add libera irc.libera.chat/6697 -ssl -autoconnect
/set irc.server.libera.nicks ${sec.data.libera_nicks}
/set irc.server.libera.sasl_mechanism PLAIN
/set irc.server.libera.sasl_username ${sec.data.libera_user}
/set irc.server.libera.sasl_password ${sec.data.libera_pass}
/set irc.server.libera.autojoin "#archlinux,#foot,#fennel,#neovim"

/server add oftc irc.oftc.net/6697 -ssl -autoconnect
/set irc.server.oftc.nicks ${sec.data.oftc_nicks}
/set irc.server.oftc.command "/msg NickServ IDENTIFY ${sec.data.oftc_pass}"
/set irc.server.oftc.command_delay 5
/set irc.server.oftc.autojoin "#alpine-linux,#suckless"

/filter addreplace irc_smart * irc_smart_filter *
EOF
