#!/bin/bash

CONFIG_PATH="$HOME/.config/VSCodium/User/profiles/7b721ef0/settings.json"
COLOR_FILE="$HOME/.config/waybar/color/colors-icons"

# Read the new color value
if [[ ! -f "$COLOR_FILE" ]]; then
    echo "Error: Color file not found!"
    exit 1
fi
NEW_COLOR=$(cat "$COLOR_FILE")

# Ensure the JSON file exists
if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "{}" > "$CONFIG_PATH"
fi

# Remove trailing commas before processing (Fixes invalid JSON)
sed -i 's/,[[:space:]]*}/}/g' "$CONFIG_PATH"

# Update JSON correctly treating keys as strings
jq --arg new_color "$NEW_COLOR" '
  .["catppuccin.accentColor"] = "pink" |
  .["catppuccin.colorOverrides"]["mocha"]["pink"] = $new_color
' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

echo "Updated $CONFIG_PATH with new color: $NEW_COLOR"