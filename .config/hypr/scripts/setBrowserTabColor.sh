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


# --- THEME

THEME_NAME="hellwal_catppuccin_chromium"

# Hardcoded colors
background="#1e1e2e"
foreground="#cdd6f4"
secondary="#b4befe"

# Read accent color from COLOR_FILE
COLOR_FILE="$HOME/.cache/hellwal/colors-icons"
if [ ! -f "$COLOR_FILE" ]; then
    echo "Accent color file not found at $COLOR_FILE"
    exit 1
fi

accent=$(cat "$COLOR_FILE")

DIR="$HOME/Pictures"
THEME_DIR="$DIR/$THEME_NAME"

# Converts hex colors into rgb joined with comma
hexToRgb() {
    plain=${1#"#"}
    printf "%d, %d, %d" 0x${plain:0:2} 0x${plain:2:2} 0x${plain:4:2}
}

prepare() {
    if [ -d "$THEME_DIR" ]; then
        rm -rf "$THEME_DIR"
    fi

    mkdir -p "$THEME_DIR"
}

background=$(hexToRgb "$background")
foreground=$(hexToRgb "$foreground")
accent=$(hexToRgb "$accent")
secondary=$(hexToRgb "$secondary")

generate() {
    cat > "$THEME_DIR/manifest.json" << EOF
    {
      "manifest_version": 3,
      "version": "2.0",
      "name": "$THEME_NAME Theme",
      "theme": {
        "colors": {
            "frame": [17, 17, 27],
            "frame_inactive": [17, 17, 27],
            "frame_incognito": [69, 71, 90],
            "frame_incognito_inactive": [69, 71, 90],
            "bookmark_text": [205, 214, 244],
            "tab_background_text": [108, 112, 134],
            "tab_background_text_inactive": [69, 71, 90],
            "tab_background_text_incognito": [205, 214, 244],
            "tab_background_text_incognito_inactive": [108, 112, 134],
            "tab_text": [205, 214, 244],
            "toolbar": [30, 30, 46],
            "toolbar_button_icon": [$accent],
            "omnibox_text": [$accent],
            "omnibox_background": [17, 17, 27],
            "ntp_background": [17, 17, 27],
            "ntp_link": [203, 166, 247],
            "ntp_text": [205, 214, 244],
            "button_background": [17, 17, 27]
        },
        "properties": {
          "ntp_background_alignment": "bottom"
        }
      }
    }
EOF
}
#     cat > "$THEME_DIR/manifest.json" << EOF
#     {
#     "manifest_version": 3,
#     "version": "3.0",
#     "name": "$THEME_NAME Theme",
#     "description": "Soothing pastel theme for Google Chrome - Catppuccin Mocha",
#     "colors": {
#       "frame": [17, 17, 27],
#       "frame_inactive": [17, 17, 27],
#       "frame_incognito": [69, 71, 90],
#       "frame_incognito_inactive": [69, 71, 90],
#       "bookmark_text": [205, 214, 244],
#       "tab_background_text": [108, 112, 134],
#       "tab_background_text_inactive": [69, 71, 90],
#       "tab_background_text_incognito": [205, 214, 244],
#       "tab_background_text_incognito_inactive": [108, 112, 134],
#       "tab_text": [205, 214, 244],
#       "toolbar": [30, 30, 46],
#       "toolbar_button_icon": [$accent],
#       "omnibox_text": [203, 166, 247],
#       "omnibox_background": [17, 17, 27],
#       "ntp_background": [17, 17, 27],
#       "ntp_link": [203, 166, 247],
#       "ntp_text": [205, 214, 244],
#       "button_background": [17, 17, 27]
#     }
# }
# EOF
# }


prepare
generate
echo "$THEME_NAME Chrome theme generated at $THEME_DIR"
