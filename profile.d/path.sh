#!/bin/sh

__profile_path_join() {
    for arg; do
        [ -n "$arg" ] && printf '%s:' "$arg"
    done
}

# XXX: by default python uses ~/.local/bin, so dunno if this is needed
# if command -v python3 >/dev/null; then
#     python -c 'import sys, site; sys.stdout.write(site.USER_BASE + "/bin")'
# or just
#     "$(python -m site --user-base)/bin"
# fi

# TODO: consider the simpler ~/.gem/ruby/*/bin

PATH="$(__profile_path_join                     \
        "$HOME/bin"                             \
        "$HOME/.local/bin"                      \
        "$(
            if command -v ruby >/dev/null; then
                # using string interpolation
                ruby -e 'print "#{Gem.user_dir}/bin"'
            fi
        )"                                      \
            "/usr/bin" \
        "$PATH"                                 \
)"

# During command expansion, the shell strips any trailing whitespace from the
# output of the command.  So if the last element of the existing PATH had
# trailing spaces or newlines, we wouldn't normally know.  There is therefore
# the common shell idiom of printing some known letter as the last output of
# every command which is then removed.  We use a ':' in this case.
export PATH="${PATH%:}"

unset __profile_path_join
