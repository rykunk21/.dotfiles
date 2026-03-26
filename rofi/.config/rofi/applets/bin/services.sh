#!/usr/bin/env bash

## Applet: Systemd Services

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

prompt='Services'
mesg="Systemd Services — Select to manage"

# Get systemd services (system and user)
get_services() {
    # Get failed services first
    systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL: " $1}' | head -5
    echo "---"
    
    # Get active user services
    systemctl --user list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
        awk '{print "USER: " $1}' | head -10
    echo "---"
    
    # Get active system services
    systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | \
        awk '{print "SYS:  " $1}' | head -10
    echo "---"
    
    # Common services quick toggle
    echo "󰐥  Restart NetworkManager"
    echo "󰐥  Restart Bluetooth"
    echo "�  Restart Pipewire"
}

# Rofi CMD
rofi_cmd() {
	rofi -theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-no-custom \
		-theme ${theme}
}

# Menu
chosen="$(get_services | rofi_cmd)"

# Execute
run_cmd() {
    case "$1" in
        "Restart NetworkManager")
            systemctl restart NetworkManager
            notify-send "Systemd" "NetworkManager restarted"
            ;;
        "Restart Bluetooth")
            systemctl restart bluetooth
            notify-send "Systemd" "Bluetooth restarted"
            ;;
        "Restart Pipewire")
            systemctl --user restart pipewire pipewire-pulse
            notify-send "Systemd" "Pipewire restarted"
            ;;
    esac
}

# Parse selection
if [[ "$chosen" == *"FAIL: "* ]]; then
    service="${chosen#*FAIL: }"
    # Show options for failed service
    action=$(echo -e "Status\nRestart\nStop\nDisable" | rofi -dmenu -p "$service" -theme ${theme})
    notify-send "Systemd" "Would $action $service"
elif [[ "$chosen" == *"USER: "* ]] || [[ "$chosen" == *"SYS:  "* ]]; then
    service="${chosen#*: }"
    action=$(echo -e "Status\nRestart\nStop" | rofi -dmenu -p "$service" -theme ${theme})
    [[ "$chosen" == *"USER:"* ]] && user_flag="--user" || user_flag=""
    case "$action" in
        "Status") systemctl $user_flag status "$service" & ;;
        "Restart") systemctl $user_flag restart "$service" && notify-send "Systemd" "Restarted $service" ;;
        "Stop") systemctl $user_flag stop "$service" && notify-send "Systemd" "Stopped $service" ;;
    esac
else
    run_cmd "$chosen"
fi
