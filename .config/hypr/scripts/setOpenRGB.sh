#!/bin/bash

# File path for color (you can update it if needed)
COLOR_FILE="$HOME/.cache/hellwal/colors-icons"

# Read the color from the file (assuming it's a single hex value)
color_hex=$(cat "$COLOR_FILE")

# Inline Python for RGB to HSV manipulation and back to HEX
new_color=$(python3 -c "
import colorsys
hex_value = '$color_hex'
r,g,b = [int(hex_value.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)]
h,s,v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
r,g,b = colorsys.hsv_to_rgb(h, 220/255, 120/255)
print('{:02x}{:02x}{:02x}'.format(round(r*255), round(g*255), round(b*255)))
")

# Set the new color using openrgb
openrgb -c "$new_color" # -d 2
