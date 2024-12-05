#
# ~/.bashrc
#

eval "$(starship init bash)"
export XDG_CONFIG_HOME="$HOME/.config"

# Add local binaries
PATH=$PATH:/home/admin/.local/bin



# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH=$PATH:/home/admin/.spicetify


