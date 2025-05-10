#
# ~/.bashrc
#

eval "$(starship init bash)"
# Add relevant enviornemnt variables
export XDG_CONFIG_HOME="$HOME/.config"
export OLLAMA_HOST=192.168.0.75


# Add surrealdb to path
PATH=$PATH:/home/admin/.surrealdb
PATH=$PATH:/home/admin/.local/bin

# Custom command aliases
alias nfzf='selected=$(fzf --preview="bat --color=always --style=numbers --line-range :500 {}"); if [ -d "$selected" ]; then cd "$selected" && nvim .; else cd "$(dirname "$selected")" && nvim "$(basename "$selected")"; fi'

alias scandisk='ncdu ~'



# CD to parent directory of file selected with fzf
alias cdfzf='if [ "$TERM" = "xterm-kitty" ]; then 
  FZF_PREVIEW_COLUMNS=${FZF_PREVIEW_COLUMNS:-80}
  FZF_PREVIEW_LINES=${FZF_PREVIEW_LINES:-24}
  selected=$(fzf --preview="~/.config/ranger/scope.sh {} $FZF_PREVIEW_COLUMNS $FZF_PREVIEW_LINES $(dirname {})/.cache/$(basename {}).png true"); 
  if [ -n "$selected" ]; then cd "$(dirname "$selected")"; fi
else
  echo "Warning: Not running in kitty terminal, image previews may not work"
  selected=$(fzf --preview="bat --color=always --style=numbers --line-range :500 {}"); 
  if [ -n "$selected" ]; then cd "$(dirname "$selected")"; fi
fi'



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



