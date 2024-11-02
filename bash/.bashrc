#
# ~/.bashrc
#

eval "$(starship init bash)"
export XDG_CONFIG_HOME="$HOME/.config"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
