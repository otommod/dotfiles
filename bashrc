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
# TODO: add some way to make the colored prompt conditional based on the
# terminal and stuff

# # set a fancy prompt (non-color, unless we know we "want" color)
# case "$TERM" in
#     xterm-color|*-256color) color_prompt=yes;;
# esac

# # uncomment for a colored prompt, if the terminal has the capability; turned
# # off by default to not distract the user: the focus in a terminal window
# # should be on the output of commands, not on the prompt
# #force_color_prompt=yes

# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# 	# We have color support; assume it's compliant with Ecma-48
# 	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# 	# a case would tend to support setf rather than setaf.)
# 	color_prompt=yes
#     else
# 	color_prompt=
#     fi
# fi

if [ -r ~/.colors//dircolors ]; then
    eval "$(dircolors -b ~/.colors/dircolors)"
fi

__prompt_command() {
    local exitcode=$?

    local RED=$'\[\e[31m\]'
    local GREEN=$'\[\e[32m\]'
    local YELLOW=$'\[\e[33m\]'
    local BLUE=$'\[\e[34m\]'
    local MAGENTA=$'\[\e[35m\]'
    local CYAN=$'\[\e[36m\]'
    local NOCOLOR=$'\[\e[0m\]'

    local workingdir=${PWD/#"$HOME"/'~'}
    workingdir=${workingdir//\//"$BLUE/$NOCOLOR"}

    local endmark="$CYAN"
    ((exitcode != 0)) && endmark="$RED"
    endmark="$endmark\$$NOCOLOR"

    # FIXME: without a host part, the prompt is just too short and not
    # attention grabbing enough (when you need to distinguish commands)
    local hostinfo=""
    # if [[ -n $SSH_CONNECTION ]]; then
        hostinfo="$GREEN\\u$NOCOLOR@$YELLOW\\h$NOCOLOR:"
    # fi

    PS1="$hostinfo$workingdir$endmark "

    # Set the title.  This is done by PS1 because we want to access the
    # prompt escapes for the title.  The escape code for setting the title is
    #       ESC ] 0 ; <title> ESC \
    # where
    #       ESC ] is OSC (Operating System Command)
    #       ESC \ is ST (String Terminator)
    # see also
    #       console_codes(4)
    # XXX: should we be checking if it's an X terminal?
    local title='\w'
    if [[ -n $SSH_CONNECTION ]]; then
        title="\\u@\\h: $title"
    fi
    PS1="\\[\\e]0;$title\\a\\]$PS1"
}
export PROMPT_COMMAND=__prompt_command

# {{{1 Settings
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# {{{2 History
# TODO: look into HISTTIMEFORMAT
export HISTFILE="$HISTDIR/bash"
export HISTCONTROL=ignorespace:ignoredups
export HISTIGNORE='exit:clear'

# append to the history file, don't overwrite it
shopt -s histappend
