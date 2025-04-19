#!/bin/bash

# Define the path to the swww cache directory
cache_dir="$HOME/.cache/swww/"

# Get a list of monitor outputs
monitor_outputs=($(ls "$cache_dir"))

# Loop through monitor outputs
for output in "${monitor_outputs[@]}"; do
    # Construct the full path to the cache file
    cache_file="$cache_dir$output"

    # Check if the cache file exists for the current monitor output
    if [ -f "$cache_file" ]; then
        # Get the wallpaper path from the cache file
        wallpaper_path=$(cat "$cache_file")

        # Copy the wallpaper to the location Rofi can access
        ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"
        convert "$wallpaper_path" -resize 40% -filter Gaussian -blur 0x8 $HOME/.config/rofi/.current_wallpaper_blur.png &

        break  # Exit the loop after processing the first found monitor output
    fi
done


# execute pywal skipping tty and terminal
# wal -i $wallpaper_path -s -t
# wallust run "$wallpaper_path" -s
# matugen --mode dark image $wallpaper_path

if [ "$1" != "theme-only" ]; then

    # Brightness adjust =========================================================
    THRESHOLD=0.5

    # Use magick to get mean brightness as a float
    BRIGHTNESS=$(magick "$wallpaper_path" -colorspace Gray -quiet -format "%[fx:mean]" info: 2>/dev/null)

    # Remove potential whitespace
    BRIGHTNESS="${BRIGHTNESS//[[:space:]]/}"

    # Compare brightness with threshold
    awk -v val="$BRIGHTNESS" -v thresh="$THRESHOLD" '
    BEGIN {
        if (val > thresh) {
            exit 0  # Bright
        } else {
            exit 1  # Dark
        }
    }
    '

    if [ $? -eq 0 ]; then
        hellwal --skip-term-colors -q -i "$wallpaper_path"
    else
        hellwal --skip-term-colors -b 0.1 -q -i "$wallpaper_path"
    fi
    # =============================================================================
else
    hellwal --skip-term-colors --theme ~/.config/hellwal/themes/custom.hellwal
fi

# hellwal --skip-term-colors -q -i "$wallpaper_path"

# OPENRGB
# NEW_COLOR_FILE="$HOME/.config/waybar/color/colors-icons-darker"
# COLOR_CODE=$(sed 's/#//' "$NEW_COLOR_FILE")
# openrgb -c "$COLOR_CODE" &

#Update icon colours
$HOME/.config/hypr/scripts/SetIconColor.sh

# Update QT accent
$HOME/.config/hypr/scripts/Update_qt_accent.sh

# Update Notification icons
$HOME/.config/hypr/scripts/SetNotiIconcolorV2.sh

# Update VScodium colour fo cat
$HOME/.config/hypr/scripts/SetVscodeColor.sh

# Update MPV UI colour
$HOME/.config/hypr/scripts/setMpvColor.sh

# Update Obsidian colour
$HOME/.config/hypr/scripts/setObsidianColor.sh

# Update Browser new tab colour
$HOME/.config/hypr/scripts/setBrowserTabColor.sh

# Update folder icon color
cp -f ~/.cache/hellwal/folder_16.svg ~/.local/share/icons/BeautyLine_pywal/places/16/folder.svg
cp -f ~/.cache/hellwal/folder_48.svg ~/.local/share/icons/BeautyLine_pywal/places/48/folder.svg

# # Copy cava config
cp -f ~/.cache/hellwal/config-cava ~/.config/cava/config