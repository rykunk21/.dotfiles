#
# ~/.bashrc
#

eval "$(starship init bash)"
export XDG_CONFIG_HOME="$HOME/.config"


# Add surrealdb to path
PATH=$PATH:/home/admin/.surrealdb
PATH=$PATH:/home/admin/.local/bin

# Custom command aliases
alias nfzf='selected=$(fzf --preview="bat --color=always --style=numbers --line-range :500 {}"); if [ -d "$selected" ]; then cd "$selected" && nvim .; else cd "$(dirname "$selected")" && nvim "$(basename "$selected")"; fi'

[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"

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


neofetch
