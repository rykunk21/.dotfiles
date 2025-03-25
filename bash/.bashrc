
# ~/.bashrc
#

eval "$(starship init bash)"
export XDG_CONFIG_HOME="$HOME/.config"

# Add local binaries
PATH=$PATH:/home/admin/.local/bin:/home/admin/.miniconda/bin


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH=$PATH:/home/admin/.spicetify


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/admin/.local/share/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/admin/.local/share/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/admin/.local/share/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/admin/.local/share/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# >>> fuzzy find >>>
eval "$(fzf --bash)"
alias nfzf='nvim $(fzf --preview="viu -t {} > /dev/null 2>&1 || bat --color=always {}")'

# <<< fuzzy find <<

