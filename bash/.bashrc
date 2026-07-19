#
# ~/.bashrc
#


if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	if uwsm check may-start; then
		exec uwsm start hyprland.desktop
	fi
fi


eval "$(starship init bash)"
# Add relevant enviornemnt variables
export XDG_CONFIG_HOME="$HOME/.config"
export OLLAMA_HOST=192.168.0.74


# Add surrealdb to path
PATH=$PATH:/home/admin/.surrealdb
PATH=$PATH:/home/admin/.local/bin
PATH=$PATH:/home/admin/.local/opt/maude

alias nfzf='selected=$(fzf --preview="bat --color=always --style=numbers --line-range :500 {}"); \
if [ -d "$selected" ]; then \
  cd "$selected" && nvim .; \
else \
  repos_dir="$HOME/repos"; \
  if [[ "$selected" == "$repos_dir"* ]]; then \
    # Extract the part after repos/, the child dir
    relative_path="${selected#$repos_dir/}"; \
    child_dir="${relative_path%%/*}"; \
    cd "$repos_dir/$child_dir" && nvim "$relative_path"; \
  else \
    cd "$(dirname "$selected")" && nvim "$(basename "$selected")"; \
  fi; \
fi'

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


export PATH="$HOME/.cargo/bin:$PATH"


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




fastfetch



