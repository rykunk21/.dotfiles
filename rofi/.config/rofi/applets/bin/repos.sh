#!/usr/bin/env bash

## Applet: Git Repositories

prompt='Repos'
mesg="Quickly open or manage git repos"
REPOS_DIR="$HOME/repos"
theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"
position="window { location: center; anchor: west; x-offset: 20px; y-offset: 0px; } listview { lines: 12; }"

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
    rofi -theme-str "$position" \
        -dmenu \
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
        url=$(rofi -theme-str "$position" -dmenu -p "Git URL" -theme "$theme")
        [ -n "$url" ] && kitty --hold -e git clone "$url" "$REPOS_DIR"/$(basename "$url" .git) 2>/dev/null &
        ;;
    *)
        name="${chosen#* }"
        name="${name% (*}"
        repo_path="$REPOS_DIR/$name"
        
        if tmux has-session -t "$name" 2>/dev/null; then
            action=$(echo -e "󰘐 Attach to existing\n󰜉 Create new session" | \
                rofi -theme-str "$position" -dmenu -p "$name exists" -theme "$theme")
            if [ "$action" = "󰘐 Attach to existing" ]; then
                kitty sh -c "tmux attach -t '$name'" 2>/dev/null &
            else
                kitty sh -c "cd '$repo_path' && tmux new-session -A -s '$name' -n 'nvim' 'nvim .'" 2>/dev/null &
            fi
        else
            kitty sh -c "cd '$repo_path' && tmux new-session -A -s '$name' -n 'nvim' 'nvim .'" 2>/dev/null &
        fi
        ;;
esac
