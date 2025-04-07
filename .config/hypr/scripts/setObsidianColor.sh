#!/bin/bash

THEME_PATH="$HOME/obsidian_vault/.obsidian/themes/AnuPpuccin/theme.css"
COLOR_FILE="$HOME/.cache/hellwal/accent_colour" # e.g., 249, 226, 175

# Read the new color value
if [[ ! -f "$COLOR_FILE" ]]; then
    echo "Error: Color file not found!"
    exit 1
fi

NEW_COLOR=$(cat "$COLOR_FILE" | tr -d '#')

# Check if theme file exists
if [[ ! -f "$THEME_PATH" ]]; then
    echo "Error: Theme file not found!"
    exit 1
fi

# Update the --ctp-yellow line
sed -i -E "s/(--ctp-yellow: var\(--ctp-custom-yellow, var\(--ctp-ext-yellow,)[^)]+/\1 $NEW_COLOR/" "$THEME_PATH"

echo "Updated --ctp-yellow in $THEME_PATH to $NEW_COLOR"
