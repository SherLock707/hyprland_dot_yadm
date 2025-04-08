#!/bin/bash

CONFIG_PATH="$HOME/.config/mpv/script-opts/uosc.conf"
COLOR_FILE="$HOME/.cache/hellwal/colors-icons"

# Read the new color value
if [[ ! -f "$COLOR_FILE" ]]; then
    echo "Error: Color file not found!"
    exit 1
fi

# Remove #
NEW_COLOR=$(sed 's/^#//' "$COLOR_FILE")

# Check if config file exists
if [[ ! -f "$CONFIG_PATH" ]]; then
    echo "Error: Config file not found!"
    exit 1
fi

# Replace the color value in the config file
sed -i "s/^color=foreground=.*/color=foreground=$NEW_COLOR/" "$CONFIG_PATH"

echo "Updated color in $CONFIG_PATH to $NEW_COLOR"