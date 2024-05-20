#!/bin/bash

# Define the SVG file path
file_path="$HOME/.config/Kvantum/Catppuccin-Mocha-Mauve-pywal/Catppuccin-Mocha-Mauve-pywal.svg"

# Define the colors file path
colors_file="$HOME/.cache/wal/colors"

# Read the new color from the 7th line of the colors file
new_color=$(sed '9q;d' "$colors_file")

# Define the pattern for the old color line
color_line_pattern="<!--PYWAL\[#.{6}\] -->"

# Read the content of the SVG file
file_content=$(<"$file_path")

# Extract the old color code from the line
old_color=$(echo "$file_content" | grep -oP "$color_line_pattern" | head -n 1 | grep -oP '#.{6}')

# echo $old_color
# echo $new_color

# Replace the old color code with the new one
if [ -n "$new_color" ]; then
    sed -i "s/$old_color/$new_color/g" "$file_path"
    # echo "Color code replaced with $new_color."
# else
#     echo "New color code not found."
fi
