#!/bin/bash

ICON_PATH="$HOME/.local/share/icons/Suru_pywall"
NEW_COLOR_FILE="$HOME/.cache/hellwal/colors-icons"
SAMPLE_CURRENT_COLOR="$HOME/.local/share/icons/Suru_pywall/apps/16/brave.svg"
PREVIOUS_COLOR="#"$(sed -n 's/.*\.ColorScheme-Text { color: #\([0-9a-fA-F]\{6\}\);.*/\1/p' "$SAMPLE_CURRENT_COLOR")
NEW_COLOR=$(cat $NEW_COLOR_FILE)
notification_color=$(echo $NEW_COLOR | sed 's/^#//')

if [ "$PREVIOUS_COLOR" == "" ]; then
    hyprctl notify -1 3000 "rgb($notification_color)" "  Previous icon colour not found."
elif [ "$PREVIOUS_COLOR" == "#" ]; then
    hyprctl notify -1 3000 "rgb($notification_color)" "  Previous icon colour not found."
elif [ "$PREVIOUS_COLOR" == "$NEW_COLOR" ]; then
    hyprctl notify -1 3000 "rgb($notification_color)" "  Same icon colour, no change."
else
    find "$ICON_PATH" -type f -name "*.svg" -exec sed -i "s/$PREVIOUS_COLOR/$NEW_COLOR/g" {} +
    # echo "Replacing $ICON_PATH $PREVIOUS_COLOR $NEW_COLOR"
fi
