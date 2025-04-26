#!/bin/bash

COLOR_INDEX=6
HEX_FILE="$HOME/.cache/hellwal/colors-icons"

if [[ ! -f "$HEX_FILE" ]]; then
    echo "Error: Hex color file not found!"
    exit 1
fi

# Read hex color and strip leading '#'
HEX_COLOR=$(sed 's/^#//' "$HEX_FILE" | tr '[:upper:]' '[:lower:]')

# Split into RGB parts
R_HEX="${HEX_COLOR:0:2}"
G_HEX="${HEX_COLOR:2:2}"
B_HEX="${HEX_COLOR:4:2}"
RGB_HEX="$R_HEX/$G_HEX/$B_HEX"

# Loop through valid numeric terminal device files
for terminal in /dev/pts/[0-9]*; do
    # Check if it's a valid, writable terminal device
    [[ -w "$terminal" && "$terminal" =~ ^/dev/pts/[0-9]+$ ]] || continue

    # Apply the color
    {
        printf '\e]4;%d;rgb:%s\a' "$COLOR_INDEX" "$RGB_HEX"
        printf '\e]10;#%s\a' "$HEX_COLOR"
    } > "$terminal" 2>/dev/null
done

# echo "Applied hex color #$HEX_COLOR (rgb:$RGB_HEX) to color index $COLOR_INDEX and foreground (slot 10)."
