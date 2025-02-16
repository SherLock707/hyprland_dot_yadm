#!/bin/bash
# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi is running and kill it if it is
if pgrep -x "rofi" > /dev/null; then
    pkill rofi
fi

# Detect monitor resolution and scale
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calculate width and height based on percentages and monitor resolution
width=$((x_mon * hypr_scale / 100))
height=$((y_mon * hypr_scale / 100))

# Set maximum width and height
max_width=1200
max_height=1000

# Set percentage of screen size for dynamic adjustment
percentage_width=90
percentage_height=100

# Calculate dynamic width and height
dynamic_width=$((width * percentage_width / 100))
dynamic_height=$((height * percentage_height / 100))

# Limit width and height to maximum values
dynamic_width=$(($dynamic_width > $max_width ? $max_width : $dynamic_width))
dynamic_height=$(($dynamic_height > $max_height ? $max_height : $dynamic_height))

# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad --width=$dynamic_width --height=$dynamic_height \
    --center \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "close this app" "" "=" "SUPER KEY (Windows Key)" "(SUPER KEY)" \
" SHIFT K" "Searchable Keybinds" "(Search all Keybinds via rofi)" \
"" "" "" \
" enter" "Terminal" "(kitty)" \
" SHIFT enter" "DropDown Terminal" "(Not available in Debian and Ubuntu)" \
" A" "Desktop Overview" "(AGS Overview)" \
" D" "Application Launcher" "(rofi-wayland)" \
" T" "Open File Manager" "(Thunar)" \
" S" "Google Search using rofi" "(rofi)" \
" Q" "close active window" "(not kill)" \
" Shift Q " "kills an active window" "(kill)" \
" Z" "Desktop Zoom" "(Not available in Debian and Ubuntu)" \
" Alt V" "Clipboard Manager" "(cliphist)" \
" W" "Choose wallpaper" "(Wallpaper Menu)" \
" Shift W" "Choose wallpaper effects" "(imagemagick + swww)" \
"CTRL ALT W" "Random wallpaper" "(via swww)" \
" B" "Hide/UnHide Waybar" "waybar" \
" CTRL B" "Choose waybar styles" "(waybar styles)" \
" ALT B" "Choose waybar layout" "(waybar layout)" \
" ALT R" "Reload Waybar swaync Rofi" "CHECK NOTIFICATION FIRST!!!" \
" SHIFT N" "Launch Notification Panel" "swaync Notification Center" \
" Print" "screenshot" "(grim)" \
" Shift Print" "screenshot region" "(grim + slurp)" \
" Shift S" "screenshot region" "(swappy)" \
" CTRL Print" "screenshot timer 5 secs " "(grim)" \
" CTRL SHIFT Print" "screenshot timer 10 secs " "(grim)" \
"ALT Print" "Screenshot active window" "active window only" \
"CTRL ALT P" "power-menu" "(wlogout)" \
"CTRL ALT L" "screen lock" "(hyprlock)" \
"CTRL ALT Del" "Hyprland Exit" "(SAVE YOUR WORK!!!)" \
" F" "Fullscreen" "Toggles to full screen" \
" CTL F" "Fake Fullscreen" "Toggles to fake full screen" \
" ALT L" "Toggle Dwindle | Master Layout" "Hyprland Layout" \
" Shift F" "Toggle float" "single window" \
" ALT F" "Toggle all windows to float" "all windows" \
" Shift B" "Toggle Blur" "normal or less blur" \
" Shift A" "Animations Menu" "Choose Animations via rofi" \
" SHIFT G" "Gamemode! All animations OFF or ON" "toggle" \
" ALT E" "Rofi Emoticons" "Emoticon" \
" ALT V" "Clipboard Manager" "cliphist" \
" H" "Launch this app" "" \
" E" "View or EDIT Keybinds, Settings, Monitor" "" \
