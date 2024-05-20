#!/bin/bash

ICON_PATH="$HOME/.local/share/icons/Suru_pywall"
NEW_COLOR_FILE="$HOME/.cache/wal/colors-icons"
SAMPLE_CURRENT_COLOR="$HOME/.local/share/icons/Suru_pywall/apps/16/brave.svg"
PREVIOUS_COLOR="#"$(sed -n 's/.*\.ColorScheme-Text { color: #\([0-9a-fA-F]\{6\}\);.*/\1/p' "$SAMPLE_CURRENT_COLOR")
NEW_COLOR=$(cat $NEW_COLOR_FILE)

if [ "$PREVIOUS_COLOR" == "" ]; then
    notify-send -u low "Previous icon colour not found"
elif [ "$PREVIOUS_COLOR" == "$NEW_COLOR" ]; then
    notify-send -u low "Same icon colour, no change"
else
    find "$ICON_PATH" -type f -name "*.svg" -exec sed -i "s/$PREVIOUS_COLOR/$NEW_COLOR/g" {} +
    # echo "Replacing $ICON_PATH $PREVIOUS_COLOR $NEW_COLOR"
fi
