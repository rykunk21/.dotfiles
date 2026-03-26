#!/usr/bin/env bash

## Applet: Docker Containers

prompt='Docker'
mesg="Manage Docker containers"
theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"
position="window { location: center; anchor: west; x-offset: 20px; y-offset: 0px; } listview { lines: 10; }"

list_containers() {
    echo "=== Running ==="
    docker ps --format "{{.Names}}" 2>/dev/null | sed 's/^/[RUN] /'
    
    echo "=== Stopped ==="
    docker ps -a --filter "status=exited" --format "{{.Names}}" 2>/dev/null | head -8 | sed 's/^/[STOP] /'
    
    echo "---"
    echo "[ACTION] Open Docker Desktop"
    echo "[ACTION] Prune System"
}

rofi_cmd() {
    rofi -theme-str "$position" \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -theme "$theme"
}

chosen="$(list_containers | rofi_cmd)"
[ -z "$chosen" ] && exit 0

prefix=$(echo "$chosen" | grep -o '^\[\w\+\]')
name=$(echo "$chosen" | sed 's/^\[\w\+\] //')

if [ "$prefix" = "[ACTION]" ]; then
    case "$name" in
        "Open Docker Desktop")
            docker-desktop &
            ;;
        "Prune System")
            confirm=$(echo -e "Yes\nNo" | rofi -theme-str "$position" -dmenu -p "Prune unused?" -theme "$theme")
            [ "$confirm" = "Yes" ] && docker system prune -f && notify-send "Docker" "System pruned"
            ;;
    esac
    exit 0
fi

# Container actions
if [ "$prefix" = "[RUN]" ]; then
    action=$(echo -e "󰓛 Stop\n󰑐 Restart\n󰈈 Kill\n󰌵 Logs\n󰆍 Shell" | \
        rofi -theme-str "$position" -dmenu -p "$name" -theme "$theme")
    
    case "$action" in
        *"Stop") docker stop "$name" && notify-send "Docker" "Stopped $name" ;;
        *"Restart") docker restart "$name" && notify-send "Docker" "Restarted $name" ;;
        *"Kill") docker kill "$name" && notify-send "Docker" "Killed $name" ;;
        *"Logs") kitty sh -c "docker logs -f '$name'" 2>/dev/null & ;;
        *"Shell") kitty sh -c "docker exec -it '$name' /bin/sh 2>/dev/null || docker exec -it '$name' /bin/bash" 2>/dev/null & ;;
    esac
else
    # Stopped container
    action=$(echo -e "󰐊 Start\n󰆴 Remove" | \
        rofi -theme-str "$position" -dmenu -p "$name" -theme "$theme")
    
    case "$action" in
        *"Start") docker start "$name" && notify-send "Docker" "Started $name" ;;
        *"Remove") docker rm "$name" && notify-send "Docker" "Removed $name" ;;
    esac
fi
