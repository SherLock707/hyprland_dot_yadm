#!/bin/bash

# Kill yad to not interfere with this binds
pkill yad || true

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Define the config files
KEYBINDS_CONF="$HOME/.config/hypr/configs/Keybinds.conf"

# Combine the contents of the keybinds files and filter for keybinds
# KEYBINDS=$(cat "$KEYBINDS_CONF" | grep -E '^(bind|bindl|binde|bindm)')
KEYBINDS=$(grep -E '^(bind|bindl|binde|bindm)' "$KEYBINDS_CONF" \
  | sed 's/^bind[a-z]* = / /; s/\$mainMod/ /g; s/,/ /g; s/exec/ /g; s/  \+/ /g; s/^ //')



# check for any keybinds to display
if [[ -z "$KEYBINDS" ]]; then
    echo "No keybinds found."
    exit 1
fi

# Use rofi to display the keybinds
echo "$KEYBINDS" | rofi -matching fuzzy -dmenu -i -p "Keybinds" -config ~/.config/rofi/config-keybinds.rasi