#!/usr/bin/env bash

## Applet: Systemd Services (with working modi tabs + actions)

theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"
position="window { location: center; anchor: west; x-offset: 20px; y-offset: 0px; }"

mkdir -p /tmp/rofi-services

# Create modi data scripts - these output the list
cat > /tmp/rofi-services/all.sh << 'EOF'
#!/bin/bash
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}' | head -10
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}' | head -20
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}' | head -25
EOF

cat > /tmp/rofi-services/failed.sh << 'EOF'
#!/bin/bash  
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}'
EOF

cat > /tmp/rofi-services/user.sh << 'EOF'
#!/bin/bash
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}'
EOF

cat > /tmp/rofi-services/system.sh << 'EOF'
#!/bin/bash
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}'
EOF

chmod +x /tmp/rofi-services/*.sh

# Run rofi with modi - this BLOCKS until user selects something
result=$(rofi \
    -theme-str "$position" \
    -modi "all:/tmp/rofi-services/all.sh,failed:/tmp/rofi-services/failed.sh,user:/tmp/rofi-services/user.sh,system:/tmp/rofi-services/system.sh" \
    -show all \
    -theme "$theme" \
    -p "Services")

# Exit if nothing selected
[ -z "$result" ] && exit 0

# Parse result: "[PREFIX] servicename"
prefix=$(echo "$result" | awk '{print $1}')
name=$(echo "$result" | awk '{print $2}')

[ -z "$name" ] && exit 0

# Set user flag
user_flag=""
[ "$prefix" = "[USER]" ] && user_flag="--user"

# Get state
if [ "$prefix" = "[USER]" ]; then
    state=$(systemctl --user is-active "$name" 2>/dev/null || echo "unknown")
elif [ "$prefix" = "[FAIL]" ]; then
    state="failed"
else
    state=$(systemctl is-active "$name" 2>/dev/null || echo "unknown")
fi

# Show action menu
action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs\n󰑮 Enable\n󰒓 Disable" | \
    rofi -theme-str "$position" -dmenu -p "$name" -mesg "State: $state" -theme "$theme")

[ -z "$action" ] && exit 0

# Execute action
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
