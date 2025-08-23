#!/bin/bash

# Kill yad to not interfere with this binds
pkill yad || true

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Function to convert modmask to human readable format
get_modifiers() {
    local modmask=$1
    local mods=""
    
    if (( modmask & 64 )); then mods="${mods} "; fi  # Super
    if (( modmask & 4 )); then mods="${mods}Ctrl+"; fi   # Ctrl
    if (( modmask & 8 )); then mods="${mods}Alt+"; fi    # Alt
    if (( modmask & 1 )); then mods="${mods}Shift+"; fi  # Shift
    
    echo "$mods"
}

# Function to get icon for dispatcher
get_dispatcher_icon() {
    local dispatcher=$1
    case $dispatcher in
        "exec") echo " " ;;
        "workspace") echo "󰖲 " ;;
        "killactive") echo "󰅖 " ;;
        "togglefloating") echo "󰉈 " ;;
        "fullscreen") echo "󰊓 " ;;
        *) echo "󰌌 " ;;
    esac
}

# Get keybinds from hyprctl and process with python for reliable JSON parsing
FORMATTED_KEYBINDS=$(hyprctl -j binds | python3 -c "
import json
import sys

try:
    data = json.load(sys.stdin)
    for bind in data:
        modmask = bind.get('modmask', 0)
        key = bind.get('key', '')
        dispatcher = bind.get('dispatcher', '')
        arg = bind.get('arg', '')
        
        if not key or not dispatcher:
            continue
            
        # Format modifiers
        mods = ''
        if modmask & 64: mods += ' '  # Super
        if modmask & 4: mods += 'Ctrl+'   # Ctrl  
        if modmask & 8: mods += 'Alt+'    # Alt
        if modmask & 1: mods += 'Shift+'  # Shift
        
        # Get dispatcher icon
        icon = ' '
        if dispatcher == 'exec': icon = ' '
        elif dispatcher == 'workspace': icon = '󰖲 '
        elif dispatcher == 'killactive': icon = '󰅖 '
        elif dispatcher == 'togglefloating': icon = '󰉈 '
        elif dispatcher == 'fullscreen': icon = '󰊓 '
        else: icon = '󰌌 '
        
        # Format key name
        formatted_key = key
        if key == 'Return': formatted_key = '󰌑 Enter'
        elif key == 'Space': formatted_key = '󱁐 Space'
        elif key == 'Escape': formatted_key = '󱊷 Esc'
        elif key == 'Tab': formatted_key = '󰌒 Tab'
        
        # Build display line
        display_line = f'{icon}{mods}{formatted_key}'
        
        # Add argument if meaningful
        if arg and dispatcher == 'exec':
            # Simplify common exec commands
            if 'foot' in arg: arg_display = 'Terminal: foot'
            elif 'kitty' in arg: arg_display = 'Terminal: kitty'  
            elif 'brave' in arg: arg_display = 'Browser: brave'
            elif 'dolphin' in arg: arg_display = 'File Manager: dolphin'
            elif 'thunar' in arg: arg_display = 'File Manager: thunar'
            elif 'rofi' in arg: arg_display = 'App Launcher'
            elif len(arg) > 50: arg_display = arg[:47] + '...'
            else: arg_display = arg
            display_line += f' → {arg_display}'
        elif arg and dispatcher != 'exec':
            display_line += f' → {arg}'
        elif dispatcher != 'exec':
            display_line += f' → {dispatcher}'
            
        print(display_line)
        
except Exception as e:
    print(f'Error parsing JSON: {e}', file=sys.stderr)
    sys.exit(1)
")

# Check if we have any keybinds to display
if [[ -z "$FORMATTED_KEYBINDS" ]]; then
    echo "No keybinds found or error parsing JSON."
    exit 1
fi

# Display in rofi
echo "$FORMATTED_KEYBINDS" | rofi -matching fuzzy -dmenu -i -p " Keybinds" -config ~/.config/rofi/config-keybinds.rasi