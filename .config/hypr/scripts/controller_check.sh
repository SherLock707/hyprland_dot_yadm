#!/bin/bash
# Checks controller and gamemode status for Waybar

if [ "$1" == "toggle" ]; then
    if [ -f /tmp/auto_gamemode_disabled ]; then
        rm /tmp/auto_gamemode_disabled
        hyprctl eval 'hl.notification.create({ text = "Auto GameMode Optimization: Enabled", icon = "ok", timeout = 2000 })'
    else
        touch /tmp/auto_gamemode_disabled
        hyprctl eval 'hl.notification.create({ text = "Auto GameMode Optimization: Disabled", icon = "info", timeout = 2000 })'
    fi
fi

# Fetch animation status (v0.55+ returns "true" or "false")
animation_raw=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if gamemoded -s | grep -q "^gamemode is active$"; then
    gamemode_status=" TRUE"
else
    gamemode_status=" FALSE"
fi

# Normalize status to 1 (enabled) or 0 (disabled) to match original words
if [[ "$animation_raw" == "true" ]] || [[ "$animation_raw" == "1" ]]; then
    ANIM_STATUS=1
else
    ANIM_STATUS=0
fi

# Determine prefix based on controller connection
if [ -e /dev/input/js1 ]; then
    PREFIX="controlleron"
else
    PREFIX="controlleroff"
fi

# Determine suffix based on animation (GameMode) state
if [[ $ANIM_STATUS -eq 1 ]]; then
    SUFFIX="gamemodeoff"
else
    SUFFIX="gamemodeon"
fi

# Determine bool text for tooltip
if [[ $ANIM_STATUS -eq 1 ]]; then
    ANIM_BOOL=" TRUE"
else
    ANIM_BOOL=" FALSE"
fi

if [ -f /tmp/auto_gamemode_disabled ]; then
    AUTO_STATUS=" FALSE"
    POSTFIX="optizationoff"
else
    AUTO_STATUS=" TRUE"
    POSTFIX="optizationon"
fi

# Output JSON for Waybar
printf '{"alt":"%s-%s-%s","tooltip":" Hyprland Animation:   %s\\n󰖺 GameModeRun:          %s\\n AutoModeOptimization: %s"}\n' \
  "$PREFIX" "$SUFFIX" "$POSTFIX" \
  "$ANIM_BOOL" "$gamemode_status" "$AUTO_STATUS"
