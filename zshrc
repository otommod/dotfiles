# Lines configured by zsh-newuser-install
HISTFILE=~/documents/dotfiles/zsh.d/history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt autocd
setopt notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/otto/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
