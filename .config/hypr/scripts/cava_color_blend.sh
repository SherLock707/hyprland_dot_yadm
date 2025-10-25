#!/usr/bin/env bash
set -euo pipefail

# Paths
COLOR_FILE="$HOME/.cache/hellwal/colors-icons"
CAVA_THEME="$HOME/.config/cava/themes/adaptive_colors"
CAVA_BLEND="$HOME/.config/hypr/scripts/cava_color_blend"

# --- Read color from file ---
if [[ ! -f "$COLOR_FILE" ]]; then
    echo "Error: Color file not found at $COLOR_FILE" >&2
    exit 1
fi

# Extract first valid hex color from the file (e.g., "#d2a39f")
HEX_COLOR=$(grep -Eo '#[0-9A-Fa-f]{6}' "$COLOR_FILE" | head -n 1)

if [[ -z "$HEX_COLOR" ]]; then
    echo "Error: No valid hex color found in $COLOR_FILE" >&2
    exit 1
fi

echo "Using color: $HEX_COLOR"

# --- Generate CAVA theme ---
"$CAVA_BLEND" "$HEX_COLOR" "$CAVA_THEME"

# --- Reload CAVA ---
if pgrep -x cava > /dev/null; then
    pkill -USR2 cava
    echo "CAVA reloaded successfully."
else
    echo "CAVA not running — theme updated but no reload signal sent."
fi
