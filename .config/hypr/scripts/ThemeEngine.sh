#!/bin/bash

# Function to send notification after all processes complete
send_completion_notification() {
    # Wait for all background jobs to complete
    wait
    hyprctl dismissnotify 2
    notification_color=$(cat "$HOME/.cache/hellwal/colors-icons" | sed 's/^#//')
    hyprctl notify -1 5000 "rgb($notification_color)" "  Theme Refresh Complete."
}

# Get current wallpaper path
wallpaper_path=$(swww query | head -n 1 | grep -oP 'image: \K.*')

# Validate wallpaper path
if [[ -z "$wallpaper_path" || ! -f "$wallpaper_path" ]]; then
    notification_color=$(cat "$HOME/.cache/hellwal/colors-icons" | sed 's/^#//')
    hyprctl notify -1 5000 "rgb($notification_color)" "  Error: Invalid wallpaper pathe."
    exit 1
fi

# Copy the wallpaper to the location Rofi can access
ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"

# Create blurred wallpaper in background
magick convert "$wallpaper_path" -resize 40% -filter Gaussian -blur 0x8 "$HOME/.config/rofi/.current_wallpaper_blur.png" &

# Apply color scheme based on mode
if [ "$1" != "theme-only" ]; then
    hellwal --skip-term-colors -q -i "$wallpaper_path" --static-background "#000000" --static-foreground "#ffffff"
else
    hellwal --skip-term-colors --theme ~/.config/hellwal/themes/custom.hellwal
fi

# Launch all theme update scripts in parallel
{
    # Update icon colours
    $HOME/.config/hypr/scripts/SetIconColor.sh
} &

{
    # Update QT accent
    $HOME/.config/hypr/scripts/Update_qt_accent.sh
} &

{
    # Update Notification icons
    $HOME/.config/hypr/scripts/SetNotiIconcolorV2.sh
} &

{
    # Update VScodium colour
    $HOME/.config/hypr/scripts/SetVscodeColor.sh
} &

{
    # Update MPV UI colour
    $HOME/.config/hypr/scripts/setMpvColor.sh
} &

{
    # Update Obsidian colour
    $HOME/.config/hypr/scripts/setObsidianColor.sh
} &

{
    # Update Terminal accent colour
    $HOME/.config/hypr/scripts/setTermColor.sh
} &

{
    # Update Browser new tab colour
    $HOME/.config/hypr/scripts/setBrowserTabColor.sh
} &

{
    # Update OPEN RGB fan
    $HOME/.config/hypr/scripts/setOpenRGB.sh
} &

{
    # Hot reload GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme ''
    gsettings set org.gnome.desktop.interface icon-theme ""
    sleep 0.1
    gsettings set org.gnome.desktop.interface gtk-theme catppuccin-mocha-mauve
    gsettings set org.gnome.desktop.interface icon-theme "'BeautyLine_pywal'"
} &

{
    # Update folder icon color
    if [[ -f ~/.cache/hellwal/folder_16.svg && -f ~/.cache/hellwal/folder_48.svg ]]; then
        cp -f ~/.cache/hellwal/folder_16.svg ~/.local/share/icons/BeautyLine_pywal/places/16/folder.svg
        cp -f ~/.cache/hellwal/folder_48.svg ~/.local/share/icons/BeautyLine_pywal/places/48/folder.svg
    fi
} &

# Start the notification function in background - it will wait for all jobs to complete
send_completion_notification

# Optional: Uncomment these if needed
# # Copy cava config
# cp -f ~/.cache/hellwal/config-cava ~/.config/cava/config

# OPENRGB alternative (commented out)
# NEW_COLOR_FILE="$HOME/.config/waybar/color/colors-icons-darker"
# if [[ -f "$NEW_COLOR_FILE" ]]; then
#     COLOR_CODE=$(sed 's/#//' "$NEW_COLOR_FILE")
#     openrgb -d 2 -c "$COLOR_CODE" &
# fi