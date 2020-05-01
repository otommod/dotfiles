# vim:fdm=marker:
#
# ~/.zshrc
#

if [ -d ~/.shrc.d ]; then
    for f in ~/.shrc.d/?*.sh; do
        [ -x "$f" ] && emulate sh -c '. "$f"'
    done
    unset f
fi

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZGEN_CUSTOM_COMPDUMP="$ZSH_CACHE_DIR/compdump"

mkdir -p "$ZSH_CACHE_DIR"

# {{{1 Terminfo

# The zsh/terminfo module makes available one builtin command:
#
#     echoti cap [ arg ]
#         Output the terminfo value corresponding to the capability cap,
#         instantiated with  arg if applicable.
#
# The zsh/terminfo module makes available one parameter:
#
#     terminfo
#         An associative array that maps terminfo capability names to their
#         values.
zmodload zsh/terminfo

# {{{1 Color
USE_COLOR=true
(( $terminfo[colors] < 8 )) && USE_COLOR=false

if [[ $USE_COLOR == true ]]; then
    autoload -Uz colors && colors
fi

ls_cmd="ls"
if (( $+commands[gls] )); then
    ls_cmd="gls"      # GNU on non-GNU systems (BSDs, macOS)
elif (( $+commands[colorls] )); then
    ls_cmd="colorls"  # OpenBSD
fi

if $ls_cmd --color >/dev/null 2>&1; then
    # GNU ls
    [[ $USE_COLOR == true ]] && ls_cmd+=" --color"
    alias ls="$ls_cmd -FhCx --group-directories-first"

elif $ls_cmd -G >/dev/null 2>&1; then
    # BSD ls
    [[ $USE_COLOR == true ]] && ls_cmd+=" -G"
    # export CLICOLOR=1
    alias ls="$ls_cmd -FhCx"
fi

alias lsd="ll -d *(-/DN)"

# {{{1 Shell options
# {{{2 Basics
setopt no_beep                  # don't beep on error
setopt combining_chars          # assume the terminal handles combining chars correctly

setopt interactive_comments     # allow comments in interactive shells
setopt rc_quotes                # when inside ' quoted strings, '' acts like '\''

unsetopt clobber                # do not overwrite files with > and >>

# {{{2 Changing directories
setopt auto_cd                  # assume "cd" when a command is a directory

setopt cdable_vars              # allows to  cd to named dirs without the ~
# setopt auto_name_dirs           # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory

setopt auto_pushd               # push the old directory onto the dirstack on cd
setopt pushd_ignore_dups        # do not store duplicates in the dirstack

# {{{2 Expansion and globbing
# setopt extended_glob            # treat #, ~, and ^ as part of patterns for filename generation

# {{{2 History
# setopt bang_hist                # use ! for history expansion
setopt extended_history         # save timestamp of command and duration

setopt append_history           # only append to the history, don't overwrite it
setopt inc_append_history       # write to history file immediately, not on shell exit
setopt share_history            # all open zshs will immediately share their histories

setopt hist_expire_dups_first   # when trimming history, delete oldest duplicates first
setopt hist_ignore_dups         # do not write events to history that are duplicates of previous events
setopt hist_ignore_space        # don't write to the history if command starts with a space
setopt hist_reduce_blanks       # condense whitespace when writing to the history
setopt hist_find_no_dups        # when searching history don't display duplicates twice

setopt hist_verify              # don't immediately execute, just expand history

# {{{2 Completion
setopt complete_in_word         # allow completion from within a word/phrase
setopt always_to_end            # move cursor to the end of a completed word

setopt auto_param_slash         # if completed parameter is a directory, add a trailing slash
setopt path_dirs                # perform path search even on command names with slashes
setopt auto_list                # Automatically list choices on ambiguous completion

setopt auto_menu                # show completion menu on successive a tab press
unsetopt menu_complete          # do not autoselect the first completion entry
unsetopt flow_control           # disable start/stop characters in shell editor

# {{{2 Correction
# setopt correct                  # spelling correction for commands
# setopt correct_all              # spelling correction for arguments

# {{{2 Prompt
# XXX: should be used only if I set the prompt myself
# setopt prompt_subst             # allow parameter and arithmetic expansion and command substitution in the prompt
setopt transient_rprompt        # only show the rprompt on the current prompt

# {{{2 Jobs
setopt long_list_jobs           # display PID when suspending processes
# setopt auto_resume              # try to resume an existing job before starting a new one
setopt notify                   # report on background jobs immediately

unsetopt bg_nice                # don't run all background jobs at a lower priority
unsetopt hup                    # don't kill jobs on shell exit
unsetopt check_jobs             # don't report on jobs when shell exits

# {{{2 Scripts and functions
# XXX: what??
# setopt multios                  # perform implicit tees or cats when multiple redirections are attempted

## {{{1 Completion
##
## XXX: '

#zstyle ':completion:*' completer _complete _match _ignored _approximate

## Makes completion behave more like vim's smartcase
#zstyle ':completion:*' matcher-list \
#    'm:{[:lower:]}={[:upper:]}'     \
#    'r:|[._-]=* r:|=*'              \
#    'l:|=* r:|=*'

## Case-insensitive (all), partial-word, and then substring completion.
## unsetopt CASE_GLOB
## zstyle ':completion:*' matcher-list                 \
##     'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'   \
##     'r:|[._-]=* r:|=*'                              \
##     'l:|=* r:|=*'

## speed up completion
#zstyle ':completion:*' accept-exact '*(N)'

## zstyle ':completion:*' use-compctl false

## Group matches and describe options
#zstyle ':completion:*' verbose true
#zstyle ':completion:*' group-name ''
#zstyle ':completion:*:options' description true
#zstyle ':completion:*:options' auto-description '%d'
## zstyle ':completion:*'              format ' %F{yellow}-- %d --%f'
#zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
#zstyle ':completion:*:corrections'  format ' %F{green}-- %d (errors: %e) --%f'
#zstyle ':completion:*:messages'     format ' %F{purple}-- %d --%f'
#zstyle ':completion:*:warnings'     format ' %F{red}-- no matches found --%f'

## Expand partial paths
#zstyle ':completion:*' expand prefix suffix

## Don't complete completion functions
#zstyle ':completion:*:functions' ignored-patterns '_*|prompt_*|pre(cmd|exec)'
## Don't complete backup files as executables
#zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '*\~'
#zstyle ':completion:*:*:-command-:*' verbose false

## Array completion element sorting.
#zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

## {{2 Cache
## For completions that use the completion caching layer
#zstyle ':completion:*' use-cache true
#zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

## {{{2 Files and directories
#zstyle ':completion:*' squeeze-slashes true
#zstyle ':completion:*' preserve-prefix '//'
#zstyle ':completion:*' list-suffixes true

## offer '..' for completion
#zstyle ':completion:*' special-dirs '..'
## zstyle ':completion:*' ignore-parents parent pwd .. directory

## Ignore multiple entries.
## Prevent offering a file (process, etc) that's already in the command line.
## (Use Alt-Comma to do something like "mv abcd.efg abcd.efg.old")
## zstyle ':completion:*:*:(rm|mv|cp|scp|diff|kill):*' ignore-line other

## Ignore some "useless" files unless we are deleting them
## This requires extended_glob to match the "^rm"
## setopt extended_glob
## zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*~' '*?.old' '*?.o' '*?.pyc' '*?.zwc'
## Alternatively, there's also $fignore

#zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
#zstyle ':completion:*:-tilde-:*' group-order named-directories path-directories users expand

## {{{2 Menu selection
#zmodload -i zsh/complist

#zstyle ':completion:*' menu select

#if [[ "$USE_COLOR" == true ]]; then
#    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#fi

## {{{2 Corrections
#zstyle ':completion:*:*:correct:*' original true
#zstyle ':completion:*:*:correct:*' insert-unambiguous true
#zstyle ':completion:*:*:correct:*' max-errors 3 numeric

## {{{2 Users
## Delete old definitions
#zstyle -d ':completion:*' users

#if [[ -r /etc/passwd ]]; then
#    # Ignore all users in /etc/passwd with shell /bin/{false,nologin} or similar.
#    zstyle ':completion:*:*:*:users' ignored-patterns \
#        "${${(M)${(f)$(</etc/passwd)}[@]:#*:*:*:*:*:*(false|nologin)}[@]%%:*}"
#else
#    # If /etc/passwd can't be read, just ignore what everybody else is ignoring
#    zstyle ':completion:*:*:*:users' ignored-patterns \
#        adm amanda apache avahi backup beaglidx bin bind cacti canna clamav   \
#        cupsys daemon dbus dictd distcache dovecot fax ftp games gdm gnats    \
#        gkrellmd gopher hacluster haldaemon halt hsqldb ident identd junkbust \
#        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios    \
#        named netdump news nfsnobody nobody nscd ntp nut nx openvpn operator  \
#        pcap postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser rpm  \
#        shutdown squid sshd sync sys uucp vcsa xfs polkitd rtkit nbd dnsmasq  \
#        mpd uuidd sddm usbmux colord git http lxc-dnsmasq avahi-autoipd       \
#        nm-openvpn solr kernoops lightdm geoclue saned usermetrics hplip      \
#        dhcpd irc syslog proxy list www-data '_*' 'systemd-*'

#fi

## ... unless we really want to.
#zstyle '*' single-ignored show

## {{{2 History
#zstyle ':completion:*:history-words' list false
#zstyle ':completion:*:history-words' menu true
#zstyle ':completion:*:history-words' stop true
#zstyle ':completion:*:history-words' remove-all-dups true

## {{{2 kill
## Completion selection by menu for kill

#zstyle ':completion:*:*:kill:*' force-list always
#zstyle ':completion:*:*:kill:*' menu true select
#zstyle ':completion:*:*:kill:*' insert-ids single

#zstyle ':completion:*:processes' command 'ps -u "$USER" -o pid,user,tty,comm'
#zstyle ':completion:*:processes' list-colors '=(#b) #([0-9]#) * ([![:space:]]*)=0=1=0'
#zstyle ':completion:*:processes' sort false

#zstyle ':completion:*:processes-names' command 'ps xho command'

## {{{2 man
## Complete manual by their section

#zstyle ':completion:*:manuals' separate-sections true
## zstyle ':completion:*:manuals.*' insert-sections true

## {{{2 ssh/scp/rsync
## Split the hosts completion into hostnames, domains and ip addresses

#zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
#zstyle ':completion:*:hosts-host'   ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
#zstyle ':completion:*:hosts-domain' ignored-patterns '^([-[:alnum:]]##.)##[-[:alnum:]]##' '<->.<->.<->.<->' '*@*'
#zstyle ':completion:*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '^(|::)([.[:xdigit:]]##:(#c,2))##(|%*)' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

#zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host hosts-ipaddr
#zstyle ':completion:*:(scp|rsync):*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr

# {{{1 Exports

HISTFILE="$HISTDIR/zsh" # The path to the history file.
HISTSIZE=100000         # The maximum number of events to save in the internal history.
SAVEHIST=100000         # The maximum number of events to save in the history file.

# TODO: do something with this
export TMUX_TERM="${TMUX_TERM-$TERM}"

# {{{1 ZLE
# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
# if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
#     function zle-line-init {
#         printf "%s" ${terminfo[smkx]}
#     }
#     function zle-line-finish {
#         printf "%s" ${terminfo[rmkx]}
#     }
#     zle -N zle-line-init
#     zle -N zle-line-finish
# fi

# Inserts 'sudo ' at the beginning of the line.
function prepend-sudo {
    if [[ $BUFFER != "sudo "* ]]; then
        BUFFER="sudo $BUFFER";
        CURSOR+=5
    fi
}
zle -N prepend-sudo
bindkey '^S' prepend-sudo

# Expands ... to ../..
function expand-dot-to-parent-directory-path {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+='/..'
    else
        LBUFFER+='.'
    fi
}
zle -N expand-dot-to-parent-directory-path

bindkey '.'  expand-dot-to-parent-directory-path
# but not during incremental search
bindkey -M isearch '.' self-insert


# Displays an indicator when completing.
function expand-or-complete-with-indicator {
    local indicator="TODO: change"
    print -Pn "$indicator"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-indicator
# bindkey '^I' expand-or-complete-with-indicator


# Makes it so that an empty command won't run (and the prompt won't advance)
function magic-enter {
    if [[ -z $BUFFER ]]; then
        zle kill-line
    else
        zle accept-line
    fi
}

zle -N magic-enter
bindkey '^M' magic-enter


# CTRL-C kills the line
bindkey '^C' kill-whole-line

# TODO: Edit the current command line in $EDITOR
# autoload -U edit-command-line
# zle -N edit-command-line

# Allows you to just write URLs with no worry of escaping
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# XXX: for complete vim correctness this should also move the cursor at the end
# of the number
autoload -U incarg

function decarg {
    NUMERIC="-${NUMERIC:-1}"
    incarg
}

zle -N increment-number incarg
zle -N decrement-number decarg

bindkey -M vicmd '^A' increment-number
bindkey -M vicmd '^X' decrement-number

# {{{1 Misc

# XXX
# setopt correct
# SPROMPT="Change '$fg[red]%R$reset_color' to '$fg[green]%r$reset_color'? ($fg[green]Yes$reset_color, $fg[red]No$reset_color, $fg[red]Abort$reset_color, $fg[yellow]Edit$reset_color) > "

# # XXX: what does this do and why is it, apparently, problematic
# function _pre_noempty {
#    stty intr "^P"
# }
# function _post_noempty {
#   stty intr "^C"
# }
# add-zsh-hook precmd _pre_noempty
# add-zsh-hook preexec _post_noempty

# {{{1 Plugins

source ~/.zgen/zgen.zsh
if ! zgen saved; then
    zgen load 'supercrabtree/k'
    zgen load 'Tarrasch/zsh-bd'

    # Themes/Prompts
    zgen load 'mafredri/zsh-async'
    zgen load 'sindresorhus/pure'
    # zgen load 'subnixr/minimal'
    # zgen load 'mreinhardt/sfz-prompt.zsh'
    # zgen load 'miekg/lean'
    # zgen load 'geometry-zsh/geometry'
    # zgen load 'romkatv/powerlevel10k' powerlevel10k

    # Completion
    zgen load 'zsh-users/zsh-completions' src

    zgen load 'zsh-users/zsh-syntax-highlighting'
    zgen load 'zsh-users/zsh-history-substring-search'  # MUST be after syntax-highlighting
    zgen load 'zsh-users/zsh-autosuggestions'           # MUST be last
    # TODO: http://stchaz.free.fr/mouse.zsh
    # TODO: https://github.com/jimhester/per-directory-history

    zgen save
fi

# {{{2 page-me
# Print a bell when a long-running command finishes
#
# First, I found
#   * https://github.com/jml/undistract-me
# It's bash only but I wrote my own version that was more portable.
# Eventually, I also found some zsh versions,
#   * the bgnotify plugin in oh-my-zsh
#   * https://github.com/marzocchi/zsh-notify
# The second one seems macOS-specific and very, very complex for what it does.
#
# Then one day, I stumbled upon
#   * https://gist.github.com/jpouellet/5278239
# Instead of desktop notifications, it uses just an ASCII bell; this (at least
# in X11-lang) marks the window as urgent which shines a bright red (at least
# in my WM).  And that's everything I need really.  I even removed the "program
# blacklist" since I don't use.
zmodload zsh/datetime

page_me_timestamp=$EPOCHSECONDS

function page_me_preexec {
    page_me_timestamp=$EPOCHSECONDS
    page_me_cmd=$1
}

function page_me_precmd {
    local elapsed=$(( $EPOCHSECONDS - page_me_timestamp ))
    if (( elapsed >= ${PAGE_ME_THRESHOLD:-10} )); then
        print -n '\a'
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd page_me_precmd
add-zsh-hook preexec page_me_preexec

# {{{2 subtitle
# Set the terminal title
# SEE ALSO
#   * http://zshwiki.org/home/examples/hardstatus
#   * https://github.com/jreese/zsh-titles

function subtitle-set-title {
    # Given
    #              BEL (ASCII bell)
    #     ESC ] is OSC (Operating System Command)
    #     ESC \ is ST (String Terminator)
    #
    # XTerm and most other terminal emulators, even tmux, support these control
    # codes:
    #     OSC <n> ; <title> ST
    #     OSC <n> ; <title> BEL
    #
    # n = 2  ->  Set the window title.
    # n = 1  ->  Set the icon name.  This is not the "app icon"; it's an X11
    #              thing.  It has been repurposed by some terminals, e.g. in
    #              iTerm2 it sets the tab title.
    # n = 0  ->  Set both the window title and the icon name.
    #
    # In tmux, the above will set the pane title.  tmux also recognizes
    #     ESC k <title> ST
    #
    # which (if the allow-rename option is set) changes the window name, a
    # different thing from a title, though the control code won't override a
    # name set by the user directly.
    #
    # SEE ALSO
    #     tmux(1)
    #     http://invisible-island.net/xterm/ctlseqs/ctlseqs.html

    # the V flag turns special characters (e.g. ASCII control chars) visible
    print "\e]0;${(V)1}\e\\"
}

function __parse_cmdname {
    local -a cmd; cmd=( ${(z)1} )

    local -i i=1
    while true; do
        case "$cmd[$i]" in
            # skip some shell syntax
            *=*) ;;
            \;|\&|\|) ;;
            \!|\&\&|\|\|) ;;
            \{|\}|\(|\)) ;;
            \[|\]|\[\[|\]\]|\(\(|\)\)) ;;

            # get the actual command out of these
            exec) ;;
            ssh|*/ssh) ;;
            sudo|*/sudo) ;;

            # get the command that is under job control
            fg) cmd=( ${(z)jobtexts[${(Q)cmd[$i+1]:-%+}]} ); i=1 ;;
            %+) cmd=( ${(z)jobtexts[${(Q)cmd[$i]}]} );       i=1 ;;

            *) break ;;
        esac

        (( i >= $#cmd )) && break
        (( i++ ))
    done

    typeset -g "$2"="${cmd[$i]:t}"
}


# Sets the tab and window titles with a given command.
function _subtitle-preexec {
    local title
    __parse_cmdname "$1" title
    subtitle-set-title "$title"
}

function _subtitle-precmd {
    # the D flag substitutes named directories
    subtitle-set-title "${(D)PWD}"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _subtitle-precmd
add-zsh-hook preexec _subtitle-preexec

# {{{2 syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line cursor root)

# ZSH_HIGHLIGHT_STYLES[default]='none'
# ZSH_HIGHLIGHT_STYLES[path]='none'
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
# ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[assign]='fg=magenta,bold'
# ZSH_HIGHLIGHT_STYLES[builtin]='fg=magenta,bold'
# ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[function]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
# ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=red,bold,standout'

# ZSH_HIGHLIGHT_STYLES[comment]='fg=10'

# ZSH_HIGHLIGHT_PATTERNS[rm*-rf*]='fg=white,bold,bg=red'

# {{{2 history-substring-search
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# TODO: use terminfo somehow
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# {{{2 autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'
# ZSH_AUTOSUGGEST_STRATEGY='match_prev_cmd'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1

# TODO: make keybindings
