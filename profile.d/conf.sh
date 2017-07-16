export PAGER=less

export EDITOR=vim
export VISUAL=vim

if [ -n "$OSTYPE" ]; then
    case "$OSTYPE" in
        darwin*)
            export BROWSER=open
            ;;
    esac
fi

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'
