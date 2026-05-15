#!/bin/bash
# Checks controller and gamemode status for Waybar

animation_raw=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
gamemode_status=$(gamemoded -s)

if [[ "$animation_raw" == "true" ]] || [[ "$animation_raw" == "1" ]]; then
    ANIM_STATUS=1
else
    ANIM_STATUS=0
fi

if [ -e /dev/input/js1 ]; then
    PREFIX="success"
else
    PREFIX="fail"
fi

if [[ $ANIM_STATUS -eq 1 ]]; then
    SUFFIX="gamemodeoff"
else
    SUFFIX="gamemodeon"
fi

# Determine bool text for tooltip
if [[ $ANIM_STATUS -eq 1 ]]; then
    ANIM_BOOL="true"
else
    ANIM_BOOL="false"
fi

# Output JSON for Waybar
echo -e "{\"alt\": \"${PREFIX}-${SUFFIX}\", \"tooltip\": \"Hyprland Animation: ${ANIM_BOOL} | GameModeRun: ${gamemode_status}\"}"