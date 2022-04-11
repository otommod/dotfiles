# vim:fdm=marker:
#
# ~/.bashrc
# executed by bash(1) for non-login shells

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# XXX: env TERM=xterm-256color is a fix for foot
# https://codeberg.org/dnkl/foot/wiki#no-colors-in-ls-output
command -v dircolors >/dev/null 2>&1 &&
  [[ -r ~/.dir_colors ]] &&
  eval "$(env TERM=xterm-256color dircolors -b ~/.dir_colors)"

# do history expansion when space entered
bind 'Space: magic-space'

# make the ** glob work (expands to all files, directories and subdirectories)
shopt -s globstar

# append to the history file, don't overwrite it
shopt -s histappend

# TODO: look into HISTTIMEFORMAT
export HISTFILE="$HISTDIR/bash"
export HISTCONTROL=ignorespace:ignoredups
export HISTIGNORE='exit:clear'

# {{{1 Prompt
if [[ -r /usr/share/git/git-prompt.sh ]]; then
    . /usr/share/git/git-prompt.sh

    GIT_PS1_SHOWCOLORHINTS=1
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM=verbose
else
  function __git_ps1 {
    (( $# > 1 )) && PS1="$1$2"
  }
fi

function _prompt_notify {
  printf '\a'
}

function _prompt_term_title {
    # Set the title.  This is done by PS1 because we want to access the
    # prompt escapes for the title.  The escape code for setting the title is
    #       ESC ] 0 ; <title> ESC \
    # where
    #       ESC ] is OSC (Operating System Command)
    #       ESC \ is ST (String Terminator)
    # see also
    #       console_codes(4)

    if _prompt_is_ssh; then
        # print the username and hostname when through SSH
        PS1+='\[\e]0;\u@\h: \w\e\\\]'
    else
        PS1+='\[\e]0;\w\e\\\]'
    fi
}

# OSC 7 notifies the terminal of the current directory for the purposes of
# opening new tabs

# https://codeberg.org/dnkl/foot/wiki#bash-and-zsh
# based on https://codeberg.org/dnkl/foot/issues/975
function _prompt_osc7() {
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

function _prompt_is_superuser {
  (( EUID == 0 ))
}

function _prompt_is_ssh {
  [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]]
}

function _prompt_has_colors {
  case $TERM in
    *-256color) return 0 ;;
    *)
      command -v tput >/dev/null 2>&1 &&
        tput colors |
        {
          read -r colors
          (( colors >= 8 ))
        }
        return
  esac
  return 1
}

_prompt_cmd_start=$SECONDS
function _prompt_preexec {
  if [[ -z $_prompt_in_precmd ]]; then
    _prompt_cmd_start=$SECONDS
    _prompt_in_precmd=true
  fi
}

trap '_prompt_preexec' DEBUG

# based on https://github.com/agkozak/polyglot
function _prompt_precmd {
  local exit=$? duration=$(( SECONDS - _prompt_cmd_start ))

  local ps1_left ps1_right
  # user and hostname
  if _prompt_is_superuser; then
    ps1_left+='\[\e[7m\]\u@\h\[\e[0m\]'
  else
    ps1_left+='\[\e[01;32m\]\u\[\e[0m\]'
    if _prompt_is_ssh; then
      ps1_left+='@\[\e[33m\]\h\[\e[0m\]'
    fi
  fi

  # cwd
  ps1_left+=' \[\e[01;34m\]\w\[\e[0m\]'

  # cmd duration
  if (( duration > 5 )); then
    local secs=$(( duration % 60 ))
    local mins=$(( duration / 60 ))
    local hours=$(( duration / 3600 ))
    if (( hours != 0 )); then
      ps1_right+="\[\e[1;33m\]${hours}h ${mins}m ${secs}s\[\e[0m\] "
    elif (( mins != 0 )); then
      ps1_right+="\[\e[33m\]${mins}m ${secs}s\[\e[0m\] "
    else
      ps1_right+="\[\e[33m\]${secs}s\[\e[0m\] "
    fi
  fi

  # exit code
  if (( exit != 0 )); then
    ps1_right+="\[\e[01;31m\]$exit\[\e[0m\] "
  fi

  ps1_right+='\$ '

  __git_ps1 "$ps1_left" " $ps1_right"

  _prompt_term_title
  _prompt_notify
  _prompt_osc7

  # NEEDS TO BE THE LAST THING
  _prompt_in_precmd=
}

PROMPT_COMMAND='_prompt_precmd'
