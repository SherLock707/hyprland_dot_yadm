#!/bin/bash

SVG_FILE="$HOME/.config/browser_custom/neon_cat.svg"
COLOR_FILE="$HOME/.cache/hellwal/colors-icons"

# Validate input files
if [[ ! -f "$COLOR_FILE" ]]; then
    echo "Error: Color file not found!"
    exit 1
fi

if [[ ! -f "$SVG_FILE" ]]; then
    echo "Error: SVG file not found!"
    exit 1
fi

# Read the new color, ensure it starts with #
NEW_COLOR=$(grep -oE '#[A-Fa-f0-9]{6}' "$COLOR_FILE" | head -n 1)

if [[ -z "$NEW_COLOR" ]]; then
    echo "Error: No valid color code found in color file!"
    exit 1
fi

# Replace the first occurrence of a hex color in the SVG
sed -i "0,/#[A-Fa-f0-9]\{6\}/s//${NEW_COLOR}/" "$SVG_FILE"

echo "✅ Updated SVG color to $NEW_COLOR in $SVG_FILE"
