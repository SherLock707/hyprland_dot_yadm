#!/bin/bash
CSS=~/.cache/hellwal/colors-waybar.css

echo -n '{ "text": "", "tooltip": "'

awk '/@define-color/ {
    name = $2; gsub(";", "", $3); color = $3;
    printf "<span foreground='\''%s'\''>██████░░░░░</span> %s: %s\\n", color, name, color;
}' "$CSS" | tr -d '\n'

echo '" }'
