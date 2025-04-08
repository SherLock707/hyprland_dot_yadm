#!/bin/bash

ICON_DIR="$HOME/.config/swaync/assets/"
NEW_COLOR_1=$(cat "$HOME/.cache/hellwal/colors-icons")
NEW_COLOR_2=$(cat "$HOME/.cache/hellwal/colors-icons-complimentary")

# Ensure colors start with #
NEW_COLOR_1="#${NEW_COLOR_1#\#}"
NEW_COLOR_2="#${NEW_COLOR_2#\#}"

echo "New colors: $NEW_COLOR_1, $NEW_COLOR_2"

# Get the first SVG file
FIRST_SVG=$(find "$ICON_DIR" -type f -name "*.svg" | head -n 1)

if [[ -z "$FIRST_SVG" ]]; then
    echo "No SVG files found in $ICON_DIR"
    exit 1
fi

# Extract the first two colors from the SVG
COLORS=($(grep -oE "#[0-9A-Fa-f]{6}" "$FIRST_SVG" | sort -u | head -n 2))

if [[ ${#COLORS[@]} -lt 2 ]]; then
    echo "Error: Could not find two distinct colors in $FIRST_SVG"
    exit 1
fi

OLD_COLOR_1=${COLORS[0]}
OLD_COLOR_2=${COLORS[1]}

# Skip replacement if colors are already correct
if [[ "$NEW_COLOR_1" == "$OLD_COLOR_1" && "$NEW_COLOR_2" == "$OLD_COLOR_2" ]]; then
    echo "Same so exiting"
    exit 0
fi

echo "Replacing $OLD_COLOR_1 → $NEW_COLOR_1"
echo "Replacing $OLD_COLOR_2 → $NEW_COLOR_2"

# Update all SVG files
find "$ICON_DIR" -type f -name "*.svg" | while read -r svg; do
    echo "Processing: $svg"

    sed -i -e "s/${OLD_COLOR_1}/${NEW_COLOR_1}/g" -e "s/${OLD_COLOR_2}/${NEW_COLOR_2}/g" "$svg"

    rsvg-convert "$svg" -o "${svg%.svg}.png"
done

echo "SVG processing and conversion complete!"
