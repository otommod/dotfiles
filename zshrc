#
# ~/.zshrc
#

if [ -d ~/.shrc.d ]; then
    for f in ~/.shrc.d/?*.sh; do
        [ -x "$f" ] && emulate sh -c '. "$f"'
    done
    unset f
fi

# XXX: perhaps do this in .zprofile or .zshenv ?
fpath+=( ~/.zsh/functions )

function __parse_cmdname {
    emulate -L zsh

    local -a cmd; cmd=( ${(z)1} )

    local c
    for c in $cmd; do
        case "$c" in
            # skip some shell syntax
            *=*) ;;
            \;|\&|\|) ;;
            \!|\&\&|\|\|) ;;
            \{|\}|\(|\)) ;;

            # skip some commands that take other commands
            exec) ;;
            ssh|*/ssh) ;;
            sudo|*/sudo) ;;

            fg) c="${(z)jobtexts[${(Q)cmd[2]:-%+}]}[1]"; break ;;
            %*) c="${(z)jobtexts[${(Q)cmd[1]}]}[1]"; break ;;

            *) break ;;
        esac
    done

    local callback="$2"
    if whence "$callback" >/dev/null; then
        "$callback" "$c" "${argv[3,-1][@]}"
    fi
}

ZCOMPDUMP_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
# Shell Options         {{{1
# Basics                     {{{2
setopt no_beep                  # don't beep on error
setopt combining_chars          # assume the terminal handles combining chars correctly

setopt interactive_comments     # allow comments even in interactive shells
setopt rc_quotes                # when inside ' quoted strings, '' acts like '\''

unsetopt clobber                # do not overwrite files with > and >>

# Changing Directories       {{{2
setopt auto_cd                  # assume "cd" when a command is a directory

setopt cdable_vars              # allows to  cd to named dirs without the ~
# setopt auto_name_dirs           # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory

setopt auto_pushd               # push the old directory onto the stack on cd
setopt pushd_ignore_dups        # do not store duplicates in the stack

# Expansion and Globbing     {{{2
# setopt extended_glob            # treat #, ~, and ^ as part of patterns for filename generation

# History                    {{{2
# setopt bang_hist                # use ! for history expansion
setopt extended_history         # save timestamp of command and duration

setopt append_history           # only append to the history, don't overwrite it
setopt inc_append_history       # add commands as they are typed, don't wait until shell exits
setopt share_history            # all open zshs will immediately share their histories

setopt hist_expire_dups_first   # when trimming history, delete oldest duplicates first
setopt hist_ignore_dups         # do not write events to history that are duplicates of previous events
setopt hist_ignore_space        # don't write to the history if command starts with a space
setopt hist_reduce_blanks       # condense whitespaces to one when writing to the history
setopt hist_find_no_dups        # when searching history don't display duplicates twice

setopt hist_verify              # don't execute immediately upon history expansion

# Completion                 {{{2
setopt complete_in_word         # allow completion from within a word/phrase
setopt always_to_end            # move cursor to the end of a completed word

setopt auto_param_slash         # if completed parameter is a directory, add a trailing slash
setopt path_dirs                # perform path search even on command names with slashes
setopt auto_list                # Automatically list choices on ambiguous completion

setopt auto_menu                # show completion menu on successive a tab press
# unsetopt menu_complete          # do not autoselect the first completion entry
unsetopt flow_control           # disable start/stop characters in shell editor

# Correction                 {{{2
# setopt correct                  # spelling correction for commands
# setopt correctall               # spelling correction for arguments

# Prompt                     {{{2
# XXX: should be used only if I set the prompt myself
# setopt prompt_subst             # allow parameter and arithmetic expansion and command substitution in the prompt
setopt transient_rprompt        # only show the rprompt on the current prompt

# Jobs                       {{{2
setopt long_list_jobs           # use more words to describe jobs
# setopt auto_resume              # try to resume an existing job before starting a new one
setopt notify                   # report on background jobs immediately

unsetopt bg_nice                # don't run all background jobs at a lower priority
unsetopt hup                    # don't kill jobs on shell exit
unsetopt check_jobs             # don't report on jobs when shell exits

# Scripts and Functions      {{{2
# XXX: what??
# setopt multios                  # perform implicit tees or cats when multiple redirections are attempted

# Completion            {{{1
#

# XXX: what does it do?
# zstyle ':completion:*' completions false

# XXX: which of the two?
# zstyle ':completion:*' completer _list _complete _ignored
# zstyle ':completion:*' completer _expand _complete _match
zstyle ':completion:*' completer _list _expand _complete _correct _approximate


zstyle ':completion:*' group-name ''
# cd to never select parent directory
zstyle ':completion:*' ignore-parents parent pwd .. directory
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-compctl true

zstyle ':completion:*' glob false
zstyle ':completion:*' matcher-list '+m:{a-z}={A-Z} r:|[._-]=** r:|=**' '' '' '+m:{a-z}={A-Z} r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 1 numeric
zstyle ':completion:*' substitute false

# Load and initialize the completion system ignoring insecure directories with
# a cache time of 20 hours, so it should almost always regenerate the first
# time a shell is opened each day.
# This is what the following glob does (yes, this is indeed a glob for zsh,
# because of the parentheses at the end)
#
#     N        expands to empty string if nothing matches with no error printed
#     mh+20    matches files that have been modified 20 hours ago or more
#
compdumpfiles=( "$ZCOMPDUMP_FILE"(Nmh+20) )

if (( ${#compdumpfiles} > 0 )); then
    printf 'redoing'
    rm "$ZCOMPDUMP_FILE"
fi

autoload -Uz compinit
compinit -i -C -d "$ZCOMPDUMP_FILE"


# Username completion.
# Delete old definitions
zstyle -d users

# ignore some common services when completing usernames
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi backup beaglidx bin bind cacti canna clamav cupsys  \
  daemon dbus dictd distcache dovecot fax ftp games gdm gnats gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident identd junkbust ldap lp mail mailman  \
  mailnull man messagebus mldonkey mysql nagios named netdump news nfsnobody  \
  nobody nscd ntp ntpd nut nx openvpn operator pcap postfix postgres privoxy  \
  pulse pvm quagga radvd rpc rpcuser rpm shutdown squid sshd sync sys uucp    \
  vcsa xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# File/directory completion, for cd command
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#lost+found' '(*/)#CVS'
#  and for all commands taking file arguments
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'

# Prevent offering a file (process, etc) that's already in the command line.
zstyle ':completion:*:(rm|cp|mv|kill|diff|scp):*' ignore-line yes
# (Use Alt-Comma to do something like "mv abcd.efg abcd.efg.old")

# Completion selection by menu for kill
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Filename suffixes to ignore during completion (except after rm command)
# This doesn't seem to work
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' '*?.old' '*?.pro' '*~'
zstyle ':completion:*:(^rm):*' ignored-patterns '*?.o' '*?.c~' '*?.old' '*?.pro' '*~'
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)CVS'
#zstyle ':completion:*:(all-|)files' file-patterns '(*~|\\#*\\#):backup-files' 'core(|.*):core\ files' '*:all-files'

zstyle ':completion:*:*:rmdir:*' file-sort time

## Use cache
# Some functions, like _apt and _dpkg, are very slow. You can use a cache in
# order to proxy the list of results (like the list of available debian
# packages)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$HOST.cache"


zmodload -i zsh/complist

# man zshcontrib
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:*' enable git #svn cvs

# Fallback to built in ls colors
zstyle ':completion:*' list-colors ''

# Make the list prompt friendly
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

# Make the selection prompt friendly when there are a lot of choices
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Add simple colors to kill
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

zstyle ':completion:*' menu select=1 _complete _ignored _approximate

# insert all expansions for expand completer
# zstyle ':completion:*:expand:*' tag-order all-expansions

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# formatting and messages
zstyle ':completion:*' verbose true
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:scp:*' tag-order files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show

# :completion:<func>:<completer>:<command>:<argument>:<tag>
# Expansion options
# zstyle ':completion:*' completer _complete _prefix
# zstyle ':completion::prefix-1:*' completer _complete
# zstyle ':completion:incremental:*' completer _complete _correct
# zstyle ':completion:predict:*' completer _complete

# Completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# Expand partial paths
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Include non-hidden directories in globbed file completions
# for certain commands
zstyle ':completion::complete:*' '\'

#  tag-order 'globbed-files directories' all-files 
zstyle ':completion::complete:*:tar:directories' file-patterns '*~.*(-/)'

# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'
zstyle ':completion:*:-command-:*:'    verbose false

# Separate matches into groups
zstyle ':completion:*:matches' group 'yes'

# Describe each match group.
zstyle ':completion:*:descriptions' format "%B---- %d%b"

# Messages/warnings format
zstyle ':completion:*:messages' format '%B%U---- %d%u%b' 
zstyle ':completion:*:warnings' format '%B%U---- no match for: %d%u%b'

# Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description 'specify: %d'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

zstyle ':completion:*:history-words' stop verbose
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false

zstyle -e ':completion:*:(ssh|scp):*' hosts 'reply=(
          ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) \
                          /dev/null)"}%%[# ]*}//,/ }
          ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
          ${${${(M)${(s:# :)${(zj:# :)${(Lf)"$([[ -f ~/.ssh/config ]] && <~/.ssh/config)"}%%\#*}}##host(|name) *}#host(|name) }/\*}
          )'

# Enable menus!

zstyle ':completion:*:correct:*'       insert-unambiguous true             # start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:man:*'      menu yes select
zstyle ':completion:*:history-words'   menu yes                            # activate menu
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select              # complete 'cd -<tab>' with menu
zstyle ':completion:*' menu select=5


# Makes completion behave more like vim's smartcase
zstyle ':completion:*'  matcher-list \
    'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# zstyle ':completion:*' auto-description 'args:%d'
# zstyle ':completion:*' expand prefix suffix
# zstyle ':completion:*' format 'completing: %d'
# zstyle ':completion:*' group-name ''
# zstyle ':completion:*' ignore-parents parent pwd
# zstyle ':completion:*' insert-unambiguous true
# zstyle ':completion:*' list-suffixes true
# zstyle ':completion:*' matcher-list '' 'l:|=* r:|=*'
# zstyle ':completion:*' max-errors 2
# zstyle ':completion:*' menu select=long
# zstyle ':completion:*' original true
# zstyle ':completion:*' prompt 'errors:%e'
# zstyle ':completion:*' select-prompt %Sscrolling%s:%p%%
# zstyle ':completion:*' squeeze-slashes true
# zstyle :compinstall filename '/home/otto/.zshrc'

#
# Styles
#

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Case-insensitive (all), partial-word, and then substring completion.
if zstyle -t ':prezto:module:completion:*' case-sensitive; then
  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  setopt CASE_GLOB
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unsetopt CASE_GLOB
fi

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
# zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*' menu yes select
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'


# Functions             {{{1
function anime {
    name=
    while getopts 'n:' opt "$@"; do
        case $opt in
            n)  name="$OPTARG" ;;
            ?)  mpv --help     ;;
        esac
    done

    scriptopts="--script-opts=anime-mode=yes"
    if [ -n "$name" ]; then
        scriptopts="$scriptopts,anime-name=$name"
    fi

    shift $((OPTIND - 1))
    mpv --msg-module "$scriptopts" $@
}


function strstrip {
    local original=$1   \
          chars=${2}    \
          left=${3:-1}  \
          right=${4:-1}
    local var=$original \
          done_any=0

    ((left )) && var="${var#"${var%%[!${chars:-[:space:]}]*}"}"  # leading
    ((right)) && var="${var%"${var##*[!${chars:-[:space:]}]}"}"  # trailing
    [[ "$var" != "$original" ]] && done_any=1

    echo "$var"
    return $((!done_any))
}

function t {
    if (($# < 1)); then
        command todo.sh ls
    else
        command todo.sh "$@"
    fi
}

# Exports               {{{1

HISTFILE="$HISTDIR/zsh" # The path to the history file.
HISTSIZE=100000         # The maximum number of events to save in the internal history.
SAVEHIST=100000         # The maximum number of events to save in the history file.

# TODO: do something with this
export TMUX_TERM="${TMUX_TERM-$TERM}"

# ZLE                   {{{1
# widgets                    {{{2
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

# Expands ... to ../..
function expand-dot-to-parent-directory-path {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+='/..'
    else
        LBUFFER+='.'
    fi
}
zle -N expand-dot-to-parent-directory-path

# Displays an indicator when completing.
function expand-or-complete-with-indicator {
    local indicator="TODO: change"
    print -Pn "$indicator"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-indicator

# }}}2

# expand history on space.
bindkey ' ' magic-space

# expand .... to ../..
bindkey '.'  expand-dot-to-parent-directory-path
# but not during incremental search
bindkey -M isearch '.' self-insert

# display an indicator when completing
# bindkey '^I' expand-or-complete-with-indicator

# insert sudo at the beginning of the line
bindkey '^S' prepend-sudo

# }}}1

# Startup Commands
if [[ -r ~/.colors//dircolors ]]; then
    eval "$(dircolors -b ~/.colors/dircolors)"
fi

# XXX: this (may be) how you set a prompt theme
autoload -U promptinit && promptinit
prompt pure

if (( $+commands[pip] )); then
    pipcomplcache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pip.complcache"

    if [[ ! -s "$pipcomplcache" || "$commands[pip]" -nt "$pipcomplcache" ]]; then
        # pip is slow; cache its output. And also support 'pip2', 'pip3' variants
        pip completion --zsh 2>/dev/null | sed -e "/^compctl/s/$/ pip2 pip3/" >! "$pipcomplcache"
    fi

    source "$pipcomplcache"
fi

# Terminfo              {{{1

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

# Terminal title        {{{1
# XXX: why is there so much code just for this?

# Sets the terminal window title.
function set-window-title {
    local title_format="%s" title_formatted
    zformat -f title_formatted "$title_format" "s:$argv"
    printf '\e]2;%s\a' "${(V%)title_formatted}"
}

# Sets the terminal tab title.
function set-tab-title {
    local title_format="%s" title_formatted
    zformat -f title_formatted "$title_format" "s:$argv"
    printf '\e]1;%s\a' "${(V%)title_formatted}"
}

# Sets the terminal multiplexer tab title.
function set-multiplexer-title {
    local title_format="%s" title_formatted
    zformat -f title_formatted "$title_format" "s:$argv"
    printf '\ek%s\e\\' "${(V%)title_formatted}"
}

# Sets the tab and window titles with a given command.
function _terminal-set-titles-with-command {
    emulate -L zsh
    setopt extended_glob

    # Get the command name that is under job control.
    if [[ "${2[(w)1]}" == (fg|%*)(\;|) ]]; then
        # Get the job name, and, if missing, set it to the default %+.
        local job_name="${${2[(wr)%*(\;|)]}:-%+}"

        # Make a local copy for use in the subshell.
        local -A jobtexts_from_parent_shell
        jobtexts_from_parent_shell=(${(kv)jobtexts})

        jobs "$job_name" 2>/dev/null | {
            read index discarded
            # The index is already surrounded by brackets: [1].
            _terminal-set-titles-with-command "${(e):-\$jobtexts_from_parent_shell$index}"
        }
    else
        # Set the command name, or in the case of sudo or ssh, the next command.
        local cmd="${${2[(wr)^(*=*|sudo|ssh|-*)]}:t}"
        local truncated_cmd="${cmd/(#m)?(#c15,)/${MATCH[1,12]}...}"
        unset MATCH

        if [[ "$TERM" == screen* ]]; then
            set-multiplexer-title "$truncated_cmd"
        fi
        set-tab-title "$truncated_cmd"
        set-window-title "$cmd"
    fi
}

# Sets the tab and window titles with a given path.
function _terminal-set-titles-with-path {
    emulate -L zsh
    setopt extended_glob

    local absolute_path="${${1:a}:-$PWD}"
    local abbreviated_path="${absolute_path/#$HOME/~}"
    local truncated_path="${abbreviated_path/(#m)?(#c15,)/...${MATCH[-12,-1]}}"
    unset MATCH

    if [[ "$TERM" == screen* ]]; then
        set-multiplexer-title "$truncated_path"
    fi
    set-tab-title "$truncated_path"
    set-window-title "$abbreviated_path"
}

autoload -Uz add-zsh-hook

# XXX: what do these functions do exactly, what's the deal with the job stuff
# add-zsh-hook precmd _terminal-set-titles-with-path
# add-zsh-hook preexec _terminal-set-titles-with-command

# Plugins               {{{1
# undistract-me              {{{2
autoload -Uz add-zsh-h

add-zsh-hook precmd __udm_precmd
add-zsh-hook preexec __udm_preexec

# command-not-found          {{{2
if [[ -f /etc/zsh_command_not_found ]]; then
    . /et/zsh_command_not_found
elif [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
    . /usr/share/doc/pkgfile/command-not-found.zsh
fi

# syntax-highlighting        {{{2
. ~/.zsh/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern line cursor root)

# ZSH_HIGHLIGHT_STYLES[builtin]='bg=blue'
# ZSH_HIGHLIGHT_STYLES[command]='bg=blue'
# ZSH_HIGHLIGHT_STYLES[function]='bg=blue'

ZSH_HIGHLIGHT_PATTERNS[rm*-rf*]='fg=white,bold,bg=red'

# history-substring-search   {{{2
# MUST be loaded after syntax-highlighting
. ~/.zsh/vendor/zsh-history-substring-search/zsh-history-substring-search.zsh

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# TODO: use terminfo somehow; prezto has some $key_info array
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# autosuggestions            {{{2
# MUST be loaded after syntax-highlighting and history-substring-search
. ~/.zsh/vendor/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
# ZSH_AUTOSUGGEST_STRATEGY='match_prev_cmd'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=1

# TODO: make keybindings
# }}}1
# vim:fdm=marker:
