#!/usr/bin/env bash

## Applet: Git Repositories

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

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
    echo "�  Open repos folder"
    echo "  Clone new repo"
}

rofi_cmd() {
	rofi -theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-theme ${theme}
}

chosen="$(list_repos | rofi_cmd)"

# Action
case "$chosen" in
    "Open repos folder")
        thunar "$REPOS_DIR" &
        ;;
    "Clone new repo")
        url=$(rofi -dmenu -p "Git URL" -theme ${theme})
        [ -n "$url" ] && kitty --hold -e git clone "$url" "$REPOS_DIR"/$(basename "$url" .git) &
        ;;
    *)
        # Extract repo name
        name="${chosen#* }"  # Remove status icon
        name="${name% (*}" # Remove branch
        repo_path="$REPOS_DIR/$name"
        
        # Submenu for repo
        action=$(echo -e "󰘐  Open in Terminal\n󰨊  Open in Editor\n󰊢  Open in File Manager\n---\n  Status\n  Pull\n  Push" | \
            rofi -dmenu -p "$name" -theme ${theme})
        
        case "$action" in
            "Open in Terminal") kitty -d "$repo_path" & ;;
            "Open in Editor") codium "$repo_path" & ;;
            "Open in File Manager") thunar "$repo_path" & ;;
            "Status") kitty --hold -d "$repo_path" -e git status & ;;
            "Pull") kitty --hold -d "$repo_path" -e git pull & ;;
            "Push") kitty --hold -d "$repo_path" -e git push & ;;
        esac
        ;;
esac
