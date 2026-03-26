#!/usr/bin/env bash

## Applet: Systemd Services (with inline actions, left-positioned)

prompt='Services'
mesg="Systemd Services — Select to manage"
theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"

# Get systemd services (increased limits, include loaded/enabled)
get_services() {
    echo "[ALL] Show all services"
    echo "[FAILED] Show failed services"
    echo "[USER] Show user services"
    echo "[SYSTEM] Show system services"
}

get_all_services() {
    # Failed services
    systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL:sys:" $1}' | head -10
    
    # All user services (not just running)
    systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | \
        awk '{print "USER:" $3 ":" $1}' | head -15
    
    # All system services (not just running)
    systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | \
        awk '{print "SYS:" $3 ":" $1}' | head -20
}

get_failed_services() {
    systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL:sys:" $1}'
}

get_user_services() {
    systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | \
        awk '{print "USER:" $3 ":" $1}'
}

get_system_services() {
    systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | \
        awk '{print "SYS:" $3 ":" $1}' | head -30
}

rofi_menu() {
    rofi -theme-str 'window {location: north west; anchor: north west; x-offset: 20px; y-offset: 50px;}' \
        -dmenu \
        -p "$1" \
        -mesg "$2" \
        -theme "$theme"
}

# Show category selector first
category=$(get_services | rofi_menu "$prompt" "$mesg")
[ -z "$category" ] && exit 0

# Get services based on category
case "$category" in
    *"ALL"*)
        service_line=$(get_all_services | rofi_menu "$prompt" "All services")
        ;;
    *"FAILED"*)
        service_line=$(get_failed_services | rofi_menu "$prompt" "Failed services")
        ;;
    *"USER"*)
        service_line=$(get_user_services | rofi_menu "$prompt" "User services")
        ;;
    *"SYSTEM"*)
        service_line=$(get_system_services | rofi_menu "$prompt" "System services")
        ;;
    *)
        exit 0
        ;;
esac

[ -z "$service_line" ] && exit 0

# Parse selection
type=$(echo "$service_line" | cut -d: -f1)
state=$(echo "$service_line" | cut -d: -f2)
name=$(echo "$service_line" | cut -d: -f3)

# Quick actions for common services
if [[ "$name" =~ ^(networkmanager|NetworkManager|bluetooth|pipewire|pipewire-pulse|rkvm-server)$ ]]; then
    quick=$(echo -e "Manage with menu\nQuick: Restart\nQuick: Stop" | rofi_menu "$name" "Quick actions available")
    
    case "$quick" in
        *"Restart")
            if [ "$name" = "pipewire" ] || [ "$name" = "pipewire-pulse" ]; then
                systemctl --user restart pipewire pipewire-pulse && notify-send "Systemd" "Pipewire restarted"
            elif [ "$type" = "USER" ]; then
                systemctl --user restart "$name" && notify-send "Systemd" "Restarted $name"
            else
                systemctl restart "$name" && notify-send "Systemd" "Restarted $name"
            fi
            exit 0
            ;;
        *"Stop")
            if [ "$type" = "USER" ]; then
                systemctl --user stop "$name" && notify-send "Systemd" "Stopped $name"
            else
                systemctl stop "$name" && notify-send "Systemd" "Stopped $name"
            fi
            exit 0
            ;;
    esac
fi

# Determine user flag
if [ "$type" = "USER" ]; then
    user_flag="--user"
elif [ "$type" = "FAIL" ]; then
    user_flag=""
else
    user_flag=""
fi

# Sanitize state for display
if [[ "$state" =~ ^(run|running|active)$ ]]; then
    current_state="running"
else
    current_state="$state"
fi

# Show action menu inline
if [ "$current_state" = "running" ] || [ "$current_state" = "active" ]; then
    action=$(echo -e "󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs" | rofi_menu "$name" "Service is $current_state — choose action")
    
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
    action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰑮 Enable\n󰒓 Disable" | rofi_menu "$name" "Service is $current_state — choose action")
    
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
        *"Enable")
            systemctl $user_flag enable "$name" && notify-send "Systemd" "Enabled $name"
            ;;
        *"Disable")
            systemctl $user_flag disable "$name" && notify-send "Systemd" "Disabled $name"
            ;;
    esac
fi
