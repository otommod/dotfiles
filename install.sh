#!/bin/bash
# vim:fdm=marker:
# install {{{
install ()
{
    local num_files="$1"; shift
    local files=()
    for (( i=0; i < $num_files; i++ )); do
        files+=( "$1" ); shift
    done
    local location="$1"
    local after_location="$2"
    local before_file="$3"
    local after_file="$4"

    if [[ $DEBUG ]]; then
        echo "$num_files"
        echo "${files[@]}"
        echo "$location"
        echo "$after_location"
        echo "$before_file"
        echo "$after_file"
    fi

    for file in ${files[@]}; do
        if [[ -L "$location/$after_location$file" ]]; then
            [[ $DEBUG ]] && echo "$location/$after_location$file"
            rm "$location/$after_location$file"
        fi
        [[ $DEBUG ]] && echo "$BASE_DIR/$before_file$file$after_file"\
                             "$location/$after_location$file"
        ln -s "$BASE_DIR/$before_file$file$after_file" "$location/$after_location$file"
    done
}
# }}}

BASE_DIR="$HOME/documents/dotfiles"

dotfiles=("bashrc"
          "zshrc"
          "dircolors"
          "tmux.conf"
          "vimrc"
          "conkyrc"
          "Xresources"
          "gtkrc-2.0"
          "gitconfig"
         )
dotdirs=( "vim"
          "mplayer"
        )
configs=( "tint2"
          "gtk-3.0"
          "htop"
          "openbox"
          "Thunar"
          "transmission"
          "viewnior"
        )

# {{{
install ${#dotfiles[@]} ${dotfiles[@]} "$HOME" "." "" ""
install ${#dotdirs[@]} ${dotdirs[@]} "$HOME" "." "" ".d"
install ${#configs[@]} ${configs[@]} "${XDG_CONFIG_HOME:-$HOME/.config}" "" "config.d/" ""
# }}}
