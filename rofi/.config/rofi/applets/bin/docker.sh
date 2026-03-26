#!/usr/bin/env bash

## Applet: Docker Containers

prompt='Docker'
mesg="Manage Docker containers"
theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"

list_containers() {
    echo "=== Running Containers ==="
    docker ps --format "{{.Names}}|{{.Image}}|{{.Status}}" 2>/dev/null | \
    while IFS='|' read name image status; do
        echo "RUN:$name|$status"
    done
    
    echo "=== Stopped Containers ==="
    docker ps -a --format "{{.Names}}|{{.Image}}|{{.Status}}" --filter "status=exited" 2>/dev/null | head -8 | \
    while IFS='|' read name image status; do
        echo "STOP:$name|stopped"
    done
    
    echo "=== Actions ==="
    echo "DESKTOP:Open Docker Desktop"
    echo "PRUNE:Prune System"
}

rofi_cmd() {
    rofi -theme-str 'window {location: center; anchor: west; x-offset: 20px; y-offset: 0px; listview {lines: 10;}}' \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -theme "$theme"
}

chosen="$(list_containers | rofi_cmd)"
[ -z "$chosen" ] && exit 0

# Parse selection
type=$(echo "$chosen" | cut -d: -f1)
data=$(echo "$chosen" | cut -d: -f2)

if [ "$type" = "DESKTOP" ]; then
    docker-desktop &
    exit 0
fi

if [ "$type" = "PRUNE" ]; then
    confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Prune unused images?" -theme "$theme")
    [ "$confirm" = "Yes" ] && docker system prune -f && notify-send "Docker" "System pruned"
    exit 0
fi

# Container actions
name=$(echo "$data" | cut -d'|' -f1)
status=$(echo "$data" | cut -d'|' -f2)

if [ "$type" = "RUN" ]; then
    action=$(echo -e "󰓛 Stop\n󰑐 Restart\n󰈈 Kill\n󰌵 Logs\n󰆍 Shell" | rofi -dmenu -p "$name" -theme "$theme")
    
    case "$action" in
        *"Stop")
            docker stop "$name" && notify-send "Docker" "Stopped $name"
            ;;
        *"Restart")
            docker restart "$name" && notify-send "Docker" "Restarted $name"
            ;;
        *"Kill")
            docker kill "$name" && notify-send "Docker" "Killed $name"
            ;;
        *"Logs")
            kitty sh -c "docker logs -f '$name'" 2>/dev/null &
            ;;
        *"Shell")
            kitty sh -c "docker exec -it '$name' /bin/sh 2>/dev/null || docker exec -it '$name' /bin/bash" 2>/dev/null &
            ;;
    esac
else
    # Stopped container
    action=$(echo -e "󰐊 Start\n󰆴 Remove" | rofi -dmenu -p "$name" -theme "$theme")
    
    case "$action" in
        *"Start")
            docker start "$name" && notify-send "Docker" "Started $name"
            ;;
        *"Remove")
            docker rm "$name" && notify-send "Docker" "Removed $name"
            ;;
    esac
fi
