#
# Executes commands at login post-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Execute code that does not affect the current session in the background.
{
    # Compile the completion dump to increase startup speed.
    if [[ -s "$ZCOMPDUMP_FILE" && (! -s "${ZCOMPDUMP_FILE}.zwc" || "$ZCOMPDUMP_FILE" -nt "${ZCOMPDUMP_FILE}.zwc") ]]; then
        zcompile "$ZCOMPDUMP_FILE"
    fi
} &!

# Print a random, hopefully interesting, adage.
if (( $+commands[fortune] )); then
    # this basically means (isatty(0) || isatty(1))
    if [[ -t 0 || -t 1 ]]; then
        fortune -s
        print
    fi
fi
