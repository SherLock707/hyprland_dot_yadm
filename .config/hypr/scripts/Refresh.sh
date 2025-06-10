#!/bin/bash

SCRIPTSDIR=$HOME/.config/hypr/scripts

# Kill already running processes
# _ps=(waybar swaync cava rofi ags)
_ps=(rofi)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# swaync-client -R -rs
swaync-client -rs
# ags -q
# relaunch apps
# swaync &
# swaync-client --reload-css &
# waybar &
# ags &
#sleep 1
#${SCRIPTSDIR}/RainbowBorders.sh &

# hyprswitch init -q --custom-css ~/.config/hyprswitch/style.css  --size-factor 4.5 --workspaces-per-row 5 &