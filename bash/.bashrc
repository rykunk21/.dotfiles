
# ~/.bashrc
#

eval "$(starship init bash)"
export XDG_CONFIG_HOME="$HOME/.config"


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
# Add software to path
export PATH=$PATH:/home/admin/.spicetify
export PATH=$PATH:/home/admin/.surrealdb
# >>> fuzzy find >>>
eval "$(fzf --bash)"
alias nfzf='nvim $(fzf --preview="viu -t {} > /dev/null 2>&1 || bat --color=always {}")'
# <<< fuzzy find <<


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/admin/.miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/admin/.miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/admin/.miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/admin/.miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

