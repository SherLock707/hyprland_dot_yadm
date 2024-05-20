#!/bin/bash

SCRIPTSDIR=$HOME/.config/hypr/scripts

# Kill already running processes
_ps=(waybar swaync cava rofi ags)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

ags -q

# relaunch apps
swaync &
waybar &
ags &
#sleep 1
#${SCRIPTSDIR}/RainbowBorders.sh &