#!/usr/bin/env bash

## Applet: Systemd Services (with modi-style tabs and actions)

theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"

# Handle action selection for a service
handle_action() {
    local type="$1"
    local name="$2"
    local state="${3:-unknown}"
    
    # Determine user flag
    local user_flag=""
    [ "$type" = "USER" ] && user_flag="--user"
    
    # Show action menu after selecting a service
    if [[ "$state" =~ ^(running|active|run|failed)$ ]] || [ "$type" = "USER" ]; then
        action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs" | \
            rofi -theme-str 'window {location: center; anchor: west; x-offset: 20px; y-offset: 0px;}' \
                -dmenu -p "$name" -mesg "Service: $name ($state)" -theme "$theme")
    else
        action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs\n󰑮 Enable\n󰒓 Disable" | \
            rofi -theme-str 'window {location: center; anchor: west; x-offset: 20px; y-offset: 0px;}' \
                -dmenu -p "$name" -mesg "Service: $name ($state)" -theme "$theme")
    fi
    
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
        *"Logs")
            kitty --hold sh -c "journalctl $user_flag -u '$name' -f" 2>/dev/null &
            ;;
        *"Enable")
            systemctl $user_flag enable "$name" && notify-send "Systemd" "Enabled $name"
            ;;
        *"Disable")
            systemctl $user_flag disable "$name" && notify-send "Systemd" "Disabled $name"
            ;;
    esac
}

# Create modi scripts
cat > /tmp/services-all.sh << 'EOF'
#!/bin/bash
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL: " $1 " (failed)"}' | head -10
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "USER: " $1}' | head -20
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "SYS: " $1}' | head -25
EOF

cat > /tmp/services-failed.sh << 'EOF'
#!/bin/bash
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "FAIL: " $1 " (failed)"}'
EOF

cat > /tmp/services-user.sh << 'EOF'
#!/bin/bash
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "USER: " $1 " | " $3}'
EOF

cat > /tmp/services-system.sh << 'EOF'
#!/bin/bash
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "SYS: " $1 " | " $3}'
EOF

chmod +x /tmp/services-*.sh

# Run rofi with modi (vertically centered, left side)
result=$(rofi \
    -theme-str 'window {location: center; anchor: west; x-offset: 20px; y-offset: 0px;}' \
    -modi "all:/tmp/services-all.sh,failed:/tmp/services-failed.sh,user:/tmp/services-user.sh,system:/tmp/services-system.sh" \
    -show all \
    -theme "$theme" \
    -p "Services")

[ -z "$result" ] && exit 0

# Parse result
type=$(echo "$result" | cut -d: -f1 | tr -d ' ')
name=$(echo "$result" | cut -d: -f2 | cut -d'|' -f1 | tr -d ' ' | awk '{print $1}')
state=$(echo "$result" | cut -d'|' -f2 | tr -d ' ' | sed 's/[()]//g')

# If name extraction failed, try alternative parsing
[ -z "$name" ] && name=$(echo "$result" | sed "s/^$type: //" | awk '{print $1}')

# Show action menu
handle_action "$type" "$name" "$state"
