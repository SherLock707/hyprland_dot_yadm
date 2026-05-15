#!/bin/bash

if [ -z "$1" ]; then
    if hyprctl getoption animations:enabled | head -n1 | grep -q "true"; then
        ACTION="enable"
    else
        ACTION="disable"
    fi
else
    case "$1" in
        enable|on)  ACTION="enable"  ;;
        disable|off) ACTION="disable" ;;
        *) ACTION="enable" ;;
    esac
fi

if [ "$ACTION" = "enable" ]; then
    hyprctl eval '
        hl.config({
            animations = { enabled = false },
            decoration = { shadow = { enabled = false }, blur = { enabled = false }, rounding = 0 },
            general = { gaps_in = 0, gaps_out = 0, border_size = 1 }
        })
        hl.window_rule({ name = "gm-op", match = { class = "^(.*)$" }, opacity = "1 override 1 override" })
    '
    
    pkill awww-daemon &
    notify-send -u low -t 2000 "GameMode Enabled" "Visual effects off."
else
    hyprctl reload
    
    (
        sleep 0.4
        if ! pgrep -x "awww-daemon" > /dev/null; then
            awww-daemon --format xrgb
        fi
    ) &
    
    notify-send -t 2000 "GameMode Disabled" "Visual effects restored."
fi