#!/bin/bash

SPECIAL_WS="special"
FOOT_CLASS="foot-dropterminal"

# Get the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.name')

# Check if foot-dropterminal exists
if hyprctl clients -j | jq -e --arg CLASS "$FOOT_CLASS" 'any(.[]; .class == $CLASS)'; then
    # If exists, check if it's in special workspace
    if hyprctl clients -j | jq -e --arg CLASS "$FOOT_CLASS" 'any(.[]; .class == $CLASS and .workspace.name == "special:special")'; then
        # Move back to current workspace and focus
        hyprctl dispatch movetoworkspace "$CURRENT_WS",class:$FOOT_CLASS
        hyprctl dispatch focuswindow class:$FOOT_CLASS
    else
        # Move to special workspace silently
        hyprctl dispatch movetoworkspacesilent $SPECIAL_WS, class:$FOOT_CLASS
    fi
else
    # If not running, start a new instance
    hyprctl dispatch exec "[float; move 15% 5%; size 70% 60%; special] foot --app-id foot-dropterminal"
fi
