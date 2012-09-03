# vim:fdm=marker:

#
# ~/.bashrc
#

# Test for an interactive shell {{{
    # This file is sourced by all *interactive* bash shells on startup,
    # including some apparently interactive shells such as scp and rcp
    # that can't tolerate any output. So make sure this doesn't display
    # anything or bad things will happen!

    if [[ $- != *i* ]]; then
        # Shell is non-interactive
        return
    fi
# }}}

# Shell Options {{{
    shopt -s autocd       # A lone directory name is treated as an argument to cd
    shopt -s cdspell      # Automatically correct mistyped directory names for cd

    shopt -s checkjobs    # Does not exit when there are jobs running

    shopt -s checkwinsize # Checks terminal window size after each command run, updating LINES and COLUMNS

    # History {{{
        shopt -s cmdhist      # Saves multi-line commands in the same history entry
        shopt -s lithist      # Saves multi-line commands with newlines instead of semicolons
        shopt -s histappend   # Appends to history instead of overwriting
        shopt -s histverify   # Disables direct execution of history substituted commands
    # }}}

    set -o vi             # Enables readline Vi editing mode
# }}}

# Environmental Variables {{{
    export EDITOR='vim'       # Set vim as the default editor
    export PAGER='less'       # Set less as the default pager

    export BROWSER='chromium' # Set chromium as the default browser

    # History {{{
        export HISTFILE=~/documents/dotfiles/bash.d/history # Where history is written
        export HISTSIZE=1000              # Save up to 1000 commands in history
        export HISTIGNORE='exit'          # Don't append the exit command in history
        export HISTCONTROL='ignoreboth'   # Don't write duplicates and lines staring with spaceblank in history
    # }}}
# }}}

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTFILESIZE=2000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1>&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
    *)
        #
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    [ -r ~/.dircolors ] && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export LANG="en_US.UTF-8"

# Solorized colour scheme {{{
function solarized {
    local S_base03="002b36"
    local S_base02="073642"
    local S_base01="586e75"
    local S_base00="657b83"
    local S_base0="839496"
    local S_base1="93a1a1"
    local S_base2="eee8d5"
    local S_base3="fdf6e3"
    local S_yellow="b58900"
    local S_orange="cb4b16"
    local S_red="dc322f"
    local S_magenta="d33682"
    local S_violet="6c71c4"
    local S_blue="268bd2"
    local S_cyan="2aa198"
    local S_green="859900"

    if [ "$TERM" = "linux" ]; then
        echo -en "\e]P0$S_base02"  # Black
        echo -en "\e]P8$S_base03"  # DarkGrey

        echo -en "\e]P1$S_red"     # DarkRed
        echo -en "\e]P9$S_orange"  # Red

        echo -en "\e]P2$S_green"   # DarkGreen
        echo -en "\e]PA$S_base01"  # Green

        echo -en "\e]P3$S_yellow"  # DarkYellow
        echo -en "\e]PB$S_base00"  # Yellow

        echo -en "\e]P4$S_blue"    # DarkBlue
        echo -en "\e]PC$S_base0"   # Blue

        echo -en "\e]P5$S_magenta" # DarkMagenta
        echo -en "\e]PD$S_violet"  # Magenta

        echo -en "\e]P6$S_cyan"    # DarkCyan
        echo -en "\e]PE$S_base1"   # Cyan

        echo -en "\e]P7$S_base2"   # LightGrey
        echo -en "\e]PF$S_base3"   # White

        clear # for background artifacting
    fi
}
# }}}

# Default colour scheme {{{
function default {
    if [ "$TERM" = "linux" ]; then
        echo -en "\e]P0000000" # Black
        echo -en "\e]P8555555" # DarkGrey

        echo -en "\e]P1AA0000" # DarkRed
        echo -en "\e]P9FF5555" # Red

        echo -en "\e]P200AA00" # DarkGreen
        echo -en "\e]PA55FF55" # Green

        echo -en "\e]P3AA5500" # Brown
        echo -en "\e]PBFFFF55" # Yellow

        echo -en "\e]P40000AA" # DarkBlue
        echo -en "\e]PC5555FF" # Blue

        echo -en "\e]P5AA00AA" # DarkMagenta
        echo -en "\e]PDFF55FF" # Magenta

        echo -en "\e]P600AAAA" # DarkCyan
        echo -en "\e]PE55FFFF" # Cyan

        echo -en "\e]P7AAAAAA" # Lightgrey
        echo -en "\e]PFFFFFFF" # White

        clear # for background artifacting
    fi
}
# }}}
