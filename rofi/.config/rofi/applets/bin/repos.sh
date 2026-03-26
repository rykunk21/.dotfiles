#!/usr/bin/env bash

## Applet: Git Repositories

prompt='Repos'
mesg="Quickly open or manage git repos"
REPOS_DIR="$HOME/repos"
theme="$HOME/.config/rofi/applets/shared/applet-theme.rasi"

list_repos() {
    find "$REPOS_DIR" -maxdepth 2 -name ".git" -type d -exec dirname {} \; 2>/dev/null | \
    while read repo; do
        name=$(basename "$repo")
        branch=$(cd "$repo" && git branch --show-current 2>/dev/null || echo "no git")
        status=$(cd "$repo" && git status --porcelain 2>/dev/null | wc -l)
        [ "$status" -gt 0 ] && status_icon="●" || status_icon="○"
        echo "$status_icon $name ($branch)"
    done | head -15
    
    echo "---"
    echo "  Open repos folder"
    echo "  Clone new repo"
}

rofi_cmd() {
    rofi -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -theme "$theme"
}

chosen="$(list_repos | rofi_cmd)"
[ -z "$chosen" ] && exit 0

case "$chosen" in
    "Open repos folder")
        thunar "$REPOS_DIR" &
        ;;
    "Clone new repo")
        url=$(rofi -dmenu -p "Git URL" -theme "$theme")
        [ -n "$url" ] && kitty --hold -e git clone "$url" "$REPOS_DIR"/$(basename "$url" .git) 2>/dev/null &
        ;;
    *)
        # Extract repo name
        name="${chosen#* }"
        name="${name% (*}"
        repo_path="$REPOS_DIR/$name"
        
        # Check if tmux session exists
        if tmux has-session -t "$name" 2>/dev/null; then
            action=$(echo -e "󰘐 Attach to existing\n󰜉 Create new session" | rofi -dmenu -p "$name exists" -theme "$theme")
            if [ "$action" = "󰘐 Attach to existing" ]; then
                kitty sh -c "tmux attach -t '$name'" 2>/dev/null &
            else
                kitty sh -c "cd '$repo_path' && tmux new-session -A -s '$name' -n 'nvim' 'nvim .'" 2>/dev/null &
            fi
        else
            # New session: cd, open tmux with nvim
            kitty sh -c "cd '$repo_path' && tmux new-session -A -s '$name' -n 'nvim' 'nvim .'" 2>/dev/null &
        fi
        ;;
esac
