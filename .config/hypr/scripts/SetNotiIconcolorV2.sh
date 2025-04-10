#!/bin/bash

ICON_DIR="$HOME/.config/swaync/assets/"
NEW_COLOR_1=$(cat "$HOME/.cache/hellwal/colors-icons")

# Ensure colors start with #
NEW_COLOR="#${NEW_COLOR_1#\#}"

# Get the first SVG file
FIRST_SVG=$(find "$ICON_DIR" -type f -name "*.svg" | head -n 1)

if [[ -z "$FIRST_SVG" ]]; then
    echo "No SVG files found in $ICON_DIR"
    exit 1
fi

# Extract the first two colors from the SVG
COLORS=($(grep -oE "#[0-9A-Fa-f]{6}" "$FIRST_SVG" | sort -u | head -n 2))

OLD_COLOR=${COLORS[0]}

# Skip replacement if colors are already correct
if [ "$NEW_COLOR" == "$OLD_COLOR" ]; then
    echo "Same so exiting"
    exit 0
fi

echo "Replacing $OLD_COLOR → $NEW_COLOR"

# Update all SVG files
find "$ICON_DIR" -type f -name "*.svg" | while read -r svg; do
    echo "Processing: $svg"

    sed -i -e "s/${OLD_COLOR}/${NEW_COLOR}/g" "$svg"

    rsvg-convert "$svg" -o "${svg%.svg}.png"
done

echo "SVG processing and conversion complete!"
