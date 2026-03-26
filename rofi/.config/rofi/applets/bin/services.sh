#!/usr/bin/env bash

## Applet: Systemd Services (reliable 3-step flow)

theme="$HOME/.config/rofi/launchers/type-1/style-9.rasi"
position="window { location: center; anchor: west; x-offset: 20px; y-offset: 0px; }"

# Step 1: Pick category
category=$(echo -e "󰒘 Failed Services\n󰄛 User Services\n󰘳 System Services\n󰡯 All Services" | \
    rofi -theme-str "$position" -dmenu -p "Services" -mesg "Select category" -theme "$theme")

[ -z "$category" ] && exit 0

# Step 2: Get services based on category
case "$category" in
    *"Failed"*)
        services=$(systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}')
        user_flag=""
        ;;
    *"User"*)
        services=$(systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}')
        user_flag="--user"
        ;;
    *"System"*)
        services=$(systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}')
        user_flag=""
        ;;
    *"All"*)
        failed=$(systemctl --failed --no-pager --no-legend 2>/dev/null | awk '{print "[FAIL] " $1}' | head -5)
        user=$(systemctl --user list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[USER] " $1}' | head -15)
        sys=$(systemctl list-units --type=service --no-pager --no-legend 2>/dev/null | awk '{print "[SYS]  " $1}' | head -20)
        services="${failed}
${user}
${sys}"
        user_flag=""
        ;;
esac

[ -z "$services" ] && { notify-send "Services" "No services found"; exit 0; }

# Step 2: Pick service
selection=$(echo "$services" | \
    rofi -theme-str "$position" -dmenu -p "Service" -mesg "Select a service" -theme "$theme")

[ -z "$selection" ] && exit 0

# Parse selection
prefix=$(echo "$selection" | awk '{print $1}')
name=$(echo "$selection" | awk '{print $2}')

# Adjust user_flag based on prefix
if [ "$prefix" = "[USER]" ]; then
    user_flag="--user"
else
    user_flag=""
fi

# Get current state
if [ "$prefix" = "[USER]" ]; then
    state=$(systemctl --user is-active "$name" 2>/dev/null || echo "unknown")
elif [ "$prefix" = "[FAIL]" ]; then
    state="failed"
else
    state=$(systemctl is-active "$name" 2>/dev/null || echo "unknown")
fi

# Step 3: Action menu
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
