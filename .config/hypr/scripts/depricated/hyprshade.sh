#!/bin/bash
#  _   _                      _               _      
# | | | |_   _ _ __  _ __ ___| |__   __ _  __| | ___ 
# | |_| | | | | '_ \| '__/ __| '_ \ / _` |/ _` |/ _ \
# |  _  | |_| | |_) | |  \__ \ | | | (_| | (_| |  __/
# |_| |_|\__, | .__/|_|  |___/_| |_|\__,_|\__,_|\___|
#        |___/|_|                                    
# 


if [[ "$1" == "headless" ]]; then
    echo "headless"
    hyprshade toggle
    exit 0
fi

# Open rofi to select the Hyprshade filter for toggle
options="  off\n$(hyprshade ls)"

# Open rofi
choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/.config/rofi/config-waybar-layout.rasi -i -no-show-icons -l 4 -width 30 -p "Hyprshade") 

# Toggle Hyprshade based on the selected filter
hyprshade_filter="blue-light-filter"

# Toggle Hyprshade
if [ "$hyprshade_filter" != "off" ] ;then
    if [ -z $(hyprshade current) ] ;then
        echo ":: hyprshade is not running"
        hyprshade on $hyprshade_filter
        notify-send "Hyprshade activated" "with $(hyprshade current)"
        echo ":: hyprshade started with $(hyprshade current)"
    else
        notify-send "Hyprshade deactivated"
        echo ":: Current hyprshade $(hyprshade current)"
        echo ":: Switching hyprshade off"
        hyprshade off
    fi
else
    if [ -z $(hyprshade current) ] ;then
        hyprshade off
    fi
    echo ":: hyprshade turned off"
fi