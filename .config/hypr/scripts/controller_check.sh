#!/bin/bash
# Checks controller and gamemode status

animation_status=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
gamemode_status=$(gamemoded -s)

# Check if /dev/input/js1 exists
if stat -c "%n" /dev/input/js1 >/dev/null 2>&1; then
    # Check the value of animations:enabled from hyprctl
    if [[ $animation_status -eq 1 ]]; then
        echo -e "{\"alt\": \"success-gamemodeoff\", \"tooltip\": \"Hyprland Animation: ${animation_status}\\\nGameModeRun: ${gamemode_status}\"}"
    else
        echo "{\"alt\": \"success-gamemodeon\"}"
    fi
else
    # Check the value of animations:enabled from hyprctl
    if [[ $animation_status -eq 1 ]]; then
        echo -e "{\"alt\": \"fail-gamemodeoff\", \"tooltip\": \"Hyprland Animation: ${animation_status}\\\nGameModeRun: ${gamemode_status}\"}"
    else
        echo "{\"alt\": \"fail-gamemodeon\"}"
    fi
fi
