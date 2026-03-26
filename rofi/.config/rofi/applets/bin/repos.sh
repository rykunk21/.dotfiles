#!/usr/bin/env bash

## Applet: Git Repositories

prompt='Repos'
mesg="Quickly open or manage git repos"

# Define your common repos here
REPOS_DIR="$HOME/repos"

list_repos() {
    # Scan for git repos (limit to 15)
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
	rofi -theme-str 'window {width: 1024px;} listview {lines: 10;}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-theme "$HOME/.config/rofi/launchers/type-1/style-9.rasi"
}

chosen="$(list_repos | rofi_cmd)"

# Action
case "$chosen" in
    "Open repos folder")
        thunar "$REPOS_DIR" &
        ;;
    "Clone new repo")
        url=$(rofi -dmenu -p "Git URL" -theme "$HOME/.config/rofi/launchers/type-1/style-9.rasi")
        [ -n "$url" ] && kitty --hold -e git clone "$url" "$REPOS_DIR"/$(basename "$url" .git) &
        ;;
    *)
        # Extract repo name
        name="${chosen#* }"  # Remove status icon
        name="${name% (*}"   # Remove branch
        repo_path="$REPOS_DIR/$name"
        
        # Open in tmux with nvim
        kitty -e bash -c "cd '$repo_path' && tmux new-session -A -s '$name' -n 'nvim' 'nvim .'" &
        ;;
esac
