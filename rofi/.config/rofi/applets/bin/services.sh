#!/usr/bin/env bash

## Applet: Systemd Services (with modi-style tabs)

theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"
position="window { location: center; anchor: west; x-offset: 20px; y-offset: 0px; }"

# Create modi scripts
mkdir -p /tmp/rofi-services

cat > /tmp/rofi-services/all.sh << 'MODI'
#!/bin/bash
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}' | head -10
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}' | head -20
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}' | head -25
MODI

cat > /tmp/rofi-services/failed.sh << 'MODI'
#!/bin/bash
systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}'
MODI

cat > /tmp/rofi-services/user.sh << 'MODI'
#!/bin/bash
systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}'
MODI

cat > /tmp/rofi-services/system.sh << 'MODI'
#!/bin/bash
systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}'
MODI

chmod +x /tmp/rofi-services/*.sh

# Run rofi with modi
result=$(rofi \
    -theme-str "$position" \
    -modi "all:/tmp/rofi-services/all.sh,failed:/tmp/rofi-services/failed.sh,user:/tmp/rofi-services/user.sh,system:/tmp/rofi-services/system.sh" \
    -show all \
    -theme "$theme" \
    -p "Services")

[ -z "$result" ] && exit 0

# Parse result
prefix=$(echo "$result" | grep -o '^\[\w\+\]' | tr -d '[]')
name=$(echo "$result" | sed 's/^\[\w\+\] //')
[ -z "$prefix" ] || [ -z "$name" ] && exit 0

# Determine user flag
user_flag=""
[ "$prefix" = "USER" ] && user_flag="--user"

# Get current state
if [ "$prefix" = "USER" ]; then
    state=$(systemctl --user is-active "$name" 2>/dev/null)
else
    state=$(systemctl is-active "$name" 2>/dev/null)
fi

# Action menu
action=$(echo -e "󰐊 Start\n󰓛 Stop\n󰑐 Restart\n󰈺 Status\n󰁯 Logs\n󰑮 Enable\n󰒓 Disable" | \
    rofi -theme-str "$position" -dmenu -p "$name" -mesg "State: $state" -theme "$theme")

[ -z "$action" ] && exit 0

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
