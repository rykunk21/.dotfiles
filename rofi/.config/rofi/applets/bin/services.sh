#!/usr/bin/env bash

## Applet: Systemd Services (with inline actions)

prompt='Services'
mesg="Systemd Services — Select to manage"
theme="$HOME/.config/rofi/applets/shared/applet-theme.rasi"

# Get systemd services
get_services() {
    echo "=== Failed Services ==="
    systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL:sys:" $1}' | head -5
    
    echo "=== User Services (running) ==="
    systemctl --user list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
        awk '{print "USER:run:" $1}' | head -8
    
    echo "=== System Services (running) ==="
    systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
        awk '{print "SYS:run:" $1}' | head -8
    
    echo "=== Quick Actions ==="
    echo "QUICK:restart:networkmanager:Restart NetworkManager"
    echo "QUICK:restart:bluetooth:Restart Bluetooth"
    echo "QUICK:restart:pipewire:Restart Pipewire"
}

rofi_menu() {
    rofi -dmenu \
        -p "$1" \
        -mesg "$2" \
        -theme "$theme"
}

# Main selection
service_line=$(get_services | rofi_menu "$prompt" "$mesg")
[ -z "$service_line" ] && exit 0

# Parse selection
type=$(echo "$service_line" | cut -d: -f1)
state=$(echo "$service_line" | cut -d: -f2)
name=$(echo "$service_line" | cut -d: -f3)

# Handle quick actions
if [ "$type" = "QUICK" ]; then
    case "$name" in
        networkmanager)
            systemctl restart NetworkManager
            notify-send "Systemd" "NetworkManager restarted"
            ;;
        bluetooth)
            systemctl restart bluetooth
            notify-send "Systemd" "Bluetooth restarted"
            ;;
        pipewire)
            systemctl --user restart pipewire pipewire-pulse
            notify-send "Systemd" "Pipewire restarted"
            ;;
    esac
    exit 0
fi

# Determine user flag and current state
if [ "$type" = "USER" ]; then
    user_flag="--user"
    current_state="$state"
elif [ "$type" = "FAIL" ]; then
    user_flag=""
    current_state="failed"
else
    user_flag=""
    current_state="$state"
fi

# Show action menu inline
if [ "$current_state" = "run" ] || [ "$current_state" = "running" ]; then
    action=$(echo -e "󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs" | rofi_menu "$name" "Service is running — choose action")
    
    case "$action" in
        *"Stop")
            systemctl $user_flag stop "$name" && notify-send "Systemd" "Stopped $name"
            ;;
        *"Restart")
            systemctl $user_flag restart "$name" && notify-send "Systemd" "Restarted $name"
            ;;
        *"Status")
            kitty --hold sh -c "systemctl $user_flag status '$name'" 2>/dev/null &
            ;;
        *"Logs")
            kitty --hold sh -c "journalctl $user_flag -u '$name' -f" 2>/dev/null &
            ;;
    esac
else
    # Failed or stopped service
    action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status" | rofi_menu "$name" "Service is $current_state — choose action")
    
    case "$action" in
        *"Start")
            systemctl $user_flag start "$name" && notify-send "Systemd" "Started $name"
            ;;
        *"Stop")
            systemctl $user_flag stop "$name" && notify-send "Systemd" "Stopped $name"
            ;;
        *"Restart")
            systemctl $user_flag restart "$name" && notify-send "Systemd" "Restarted $name"
            ;;
        *"Status")
            kitty --hold sh -c "systemctl $user_flag status '$name'" 2>/dev/null &
            ;;
    esac
fi
