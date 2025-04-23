#!/bin/bash

WALLPAPER=$(cat ~/.cache/wal/wal)

cat > ~/.config/hypr/hyprpaper.conf << EOF 
preload = $WALLPAPER
wallpaper = , $WALLPAPER
EOF
