#!/usr/bin/env bash

## Applet: Docker Containers

source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

prompt='Docker'
mesg="Manage Docker containers"

list_containers() {
    # Running containers
    docker ps --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>/dev/null | \
    while IFS='|' read name image status; do
        echo "󰐱 $name | $status"
    done
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "---"
    fi
    
    # Stopped containers (first 5)
    docker ps -a --format "{{.Names}}|{{.Image}}|{{.Status}}" --filter "status=exited" 2>/dev/null | head -5 | \
    while IFS='|' read name image status; do
        echo "󰒲 $name | stopped"
    done
    
    echo "---"
    echo "󰐈  Open Docker Desktop"
    echo "󰜝  Prune"
}

rofi_cmd() {
	rofi -theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-theme ${theme}
}

chosen="$(list_containers | rofi_cmd)"

# Parse selection
if [[ "$chosen" == *"Open Docker Desktop"* ]]; then
    docker-desktop &
elif [[ "$chosen" == *"Prune"* ]]; then
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Prune unused images?" -theme ${theme})
    [ "$confirm" = "Yes" ] && docker system prune -f && notify-send "Docker" "System pruned"
else
    # Extract container name
    name="${chosen#* }"  # Remove icon
    name="${name%% |*}"  # Remove status
    
    # Check if running
    if [[ "$chosen" == *"󰐱"* ]]; then
        action=$(echo -e "Stop\nRestart\nLogs\nShell" | rofi -dmenu -p "$name" -theme ${theme})
        case "$action" in
            Stop) docker stop "$name" && notify-send "Docker" "Stopped $name" ;;
            Restart) docker restart "$name" && notify-send "Docker" "Restarted $name" ;;
            Logs) kitty --hold -e docker logs -f "$name" & ;;
            Shell) kitty -e docker exec -it "$name" /bin/sh & || \
                   kitty -e docker exec -it "$name" /bin/bash & ;;
        esac
    else
        # Stopped container
        action=$(echo -e "Start\nRemove" | rofi -dmenu -p "$name" -theme ${theme})
        case "$action" in
            Start) docker start "$name" && notify-send "Docker" "Started $name" ;;
            Remove) docker rm "$name" && notify-send "Docker" "Removed $name" ;;
        esac
    fi
fi
