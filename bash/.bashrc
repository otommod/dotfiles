# vim:fdm=marker:
#
# ~/.bashrc
# executed by bash(1) for non-login shells

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


if [ -d ~/.shrc.d ]; then
    for f in ~/.shrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# do history expansion when space entered
bind 'Space: magic-space'

# {{{1 Prompt
# XXX: https://blog.w1r3.net/2018/07/07/portable-shell-prompt.html

. ~/.shrc.d/polyglot/polyglot.sh
bind 'set show-mode-in-prompt off'

# print a bell to get notified when the command ends
PROMPT_COMMAND+="; printf '\a'"

# {{{2 git
if [ -f /usr/share/git/git-prompt.sh ]; then
    . /usr/share/git/git-prompt.sh

    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM=verbose

    # monkey-patch polyglot for faster git
    function _polyglot_branch_status {
        __git_ps1 ' (%s)'
    }
fi

# {{{2 terminal title
function __prompt_set_title {
    # Set the title.  This is done by PS1 because we want to access the
    # prompt escapes for the title.  The escape code for setting the title is
    #       ESC ] 0 ; <title> ESC \
    # where
    #       ESC ] is OSC (Operating System Command)
    #       ESC \ is ST (String Terminator)
    # see also
    #       console_codes(4)

    if [[ -n $SSH_CONNECTION ]]; then
        # print the username and hostname when through SSH
        PS1+='\[\e]0;\u@\h: \w\e\\\]'
    else
        PS1+='\[\e]0;\w\e\\\]'
    fi
}

PROMPT_COMMAND+="; __prompt_set_title"

# {{{2 OSC 7
# OSC 7 notifies the terminal of the current directory for the purposes of
# opening new tabs

# https://codeberg.org/dnkl/foot/wiki#bash-and-zsh
# based on https://codeberg.org/dnkl/foot/issues/975
function osc7_cwd() {
  printf '\e]7;file://%s' "$HOSTNAME"

  # URL-encode the `$PWD`
  local i c strlen=${#PWD}
  for (( i = 0; i < strlen; i++ )); do
    c=${PWD:$i:1}
    case "$c" in
      [-._~/a-zA-Z0-9]) printf '%s' "$c" ;;
      *) printf '%%%02X' "$c" ;;
    esac
  done

  printf '\e\\'
}

PROMPT_COMMAND+="; osc7_cwd"

# {{{1 Settings
# check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will match all
# files and zero or more directories and subdirectories.
#shopt -s globstar

# {{{2 History
# TODO: look into HISTTIMEFORMAT
export HISTFILE="$HISTDIR/bash"
export HISTCONTROL=ignorespace:ignoredups
export HISTIGNORE='exit:clear'

# append to the history file, don't overwrite it
shopt -s histappend
