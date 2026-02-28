#!/bin/bash

# Usage: ./dropdown.sh [-d] <terminal_command>
# Example: ./dropdown.sh foot
#          ./dropdown.sh -d foot (with debug output)
#          ./dropdown.sh "kitty -e zsh"
#          ./dropdown.sh "alacritty --working-directory /home/user"

DEBUG=false
SPECIAL_WS="special:scratchpad"
ADDR_FILE="/tmp/dropdown_terminal_addr"

# Dropdown size and position configuration (percentages)
WIDTH_PERCENT=50  # Width as percentage of screen width
HEIGHT_PERCENT=50 # Height as percentage of screen height
Y_PERCENT=5       # Y position as percentage from top (X is auto-centered)

# Animation settings
SLIDE_STEPS=8
SLIDE_DELAY=0.02  # seconds between steps

# Parse arguments
if [ "$1" = "-d" ]; then
    DEBUG=true
    shift
fi

TERMINAL_CMD="$1"

# Debug echo function
debug_echo() {
    if [ "$DEBUG" = true ]; then
        echo "$@"
    fi
}

# Validate input
if [ -z "$TERMINAL_CMD" ]; then
    echo "Missing terminal command. Usage: $0 [-d] <terminal_command>"
    echo "Examples:"
    echo "  $0 foot"
    echo "  $0 -d foot (with debug output)"
    echo "  $0 'kitty -e zsh'"
    echo "  $0 'alacritty --working-directory /home/user'"
    echo ""
    echo "Edit the script to modify size and position:"
    echo "  WIDTH_PERCENT  - Width as percentage of screen (default: 50)"
    echo "  HEIGHT_PERCENT - Height as percentage of screen (default: 50)"
    echo "  Y_PERCENT      - Y position from top as percentage (default: 5)"
    echo "  Note: X position is automatically centered"
    exit 1
fi

# Function to get window geometry
get_window_geometry() {
    local addr="$1"
    hyprctl clients -j | jq -r --arg ADDR "$addr" '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
}

# Function to animate window slide down (show)
animate_slide_down() {
    local addr="$1"
    local target_x="$2"
    local target_y="$3"
    local width="$4"
    local height="$5"

    debug_echo "Animating slide down to $target_x,$target_y"

    # Start above screen
    local start_y=$((-height - 50))
    local step_y=$(((target_y - start_y) / SLIDE_STEPS))

    # Place at start position instantly
    hyprctl dispatch movewindowpixel "exact $target_x $start_y,address:$addr" >/dev/null 2>&1
    sleep 0.03

    for i in $(seq 1 $SLIDE_STEPS); do
        local current_y=$((start_y + step_y * i))
        hyprctl dispatch movewindowpixel "exact $target_x $current_y,address:$addr" >/dev/null 2>&1
        sleep $SLIDE_DELAY
    done

    # Ensure exact final position
    hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$addr" >/dev/null 2>&1
}

# Function to animate window slide up (hide)
animate_slide_up() {
    local addr="$1"
    local start_x="$2"
    local start_y="$3"
    local width="$4"
    local height="$5"

    debug_echo "Animating slide up from $start_x,$start_y"

    # End position: above screen
    local end_y=$((-height - 50))
    local step_y=$(((start_y - end_y) / SLIDE_STEPS))

    for i in $(seq 1 $SLIDE_STEPS); do
        local current_y=$((start_y - step_y * i))
        hyprctl dispatch movewindowpixel "exact $start_x $current_y,address:$addr" >/dev/null 2>&1
        sleep $SLIDE_DELAY
    done

    debug_echo "Slide up complete"
}

# Function to get monitor info including scale
get_monitor_info() {
    local monitor_data=$(hyprctl monitors -j | jq -r '.[0] | "\(.x) \(.y) \(.width) \(.height) \(.scale)"')

    if [ -z "$monitor_data" ] || [ "$monitor_data" = "null null null null null" ]; then
        debug_echo "Error: Could not get monitor information"
        return 1
    fi

    echo "$monitor_data"
}

# Function to calculate dropdown position with proper scaling and centering
calculate_dropdown_position() {
    local monitor_info=$(get_monitor_info)

    if [ $? -ne 0 ] || [ -z "$monitor_info" ]; then
        debug_echo "Error: Failed to get monitor info, using fallback values"
        echo "100 100 800 600"
        return 1
    fi

    local mon_x=$(echo $monitor_info | cut -d' ' -f1)
    local mon_y=$(echo $monitor_info | cut -d' ' -f2)
    local mon_width=$(echo $monitor_info | cut -d' ' -f3)
    local mon_height=$(echo $monitor_info | cut -d' ' -f4)
    local mon_scale=$(echo $monitor_info | cut -d' ' -f5)

    debug_echo "Monitor info: x=$mon_x, y=$mon_y, width=$mon_width, height=$mon_height, scale=$mon_scale"

    if [ -z "$mon_scale" ] || [ "$mon_scale" = "null" ] || [ "$mon_scale" = "0" ]; then
        debug_echo "Invalid scale value, using 1.0 as fallback"
        mon_scale="1.0"
    fi

    local logical_width logical_height
    if command -v bc >/dev/null 2>&1; then
        logical_width=$(echo "scale=0; $mon_width / $mon_scale" | bc | cut -d'.' -f1)
        logical_height=$(echo "scale=0; $mon_height / $mon_scale" | bc | cut -d'.' -f1)
    else
        local scale_int=$(echo "$mon_scale" | sed 's/\.//' | sed 's/^0*//')
        if [ -z "$scale_int" ]; then scale_int=100; fi
        logical_width=$(((mon_width * 100) / scale_int))
        logical_height=$(((mon_height * 100) / scale_int))
    fi

    if ! [[ "$logical_width" =~ ^-?[0-9]+$ ]]; then logical_width=$mon_width; fi
    if ! [[ "$logical_height" =~ ^-?[0-9]+$ ]]; then logical_height=$mon_height; fi

    debug_echo "Physical resolution: ${mon_width}x${mon_height}"
    debug_echo "Logical resolution: ${logical_width}x${logical_height}"

    local width=$((logical_width * WIDTH_PERCENT / 100))
    local height=$((logical_height * HEIGHT_PERCENT / 100))
    local y_offset=$((logical_height * Y_PERCENT / 100))
    local x_offset=$(((logical_width - width) / 2))
    local final_x=$((mon_x + x_offset))
    local final_y=$((mon_y + y_offset))

    debug_echo "Window size: ${width}x${height}"
    debug_echo "Final position: x=$final_x, y=$final_y"

    echo "$final_x $final_y $width $height"
}

# Get the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Function to get stored terminal address
get_terminal_address() {
    if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
        cat "$ADDR_FILE"
    fi
}

# Function to check if terminal exists
terminal_exists() {
    local addr=$(get_terminal_address)
    if [ -n "$addr" ]; then
        hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR)' >/dev/null 2>&1
    else
        return 1
    fi
}

# Function to check if terminal is in special workspace
terminal_in_special() {
    local addr=$(get_terminal_address)
    if [ -n "$addr" ]; then
        hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR and .workspace.name == "special:scratchpad")' >/dev/null 2>&1
    else
        return 1
    fi
}

# Function to spawn terminal and capture its address
spawn_terminal() {
    debug_echo "Creating new dropdown terminal with command: $TERMINAL_CMD"

    local pos_info=$(calculate_dropdown_position)
    if [ $? -ne 0 ]; then
        debug_echo "Warning: Using fallback positioning"
    fi

    local target_x=$(echo $pos_info | cut -d' ' -f1)
    local target_y=$(echo $pos_info | cut -d' ' -f2)
    local width=$(echo $pos_info | cut -d' ' -f3)
    local height=$(echo $pos_info | cut -d' ' -f4)

    debug_echo "Target position: ${target_x},${target_y}, size: ${width}x${height}"

    local windows_before=$(hyprctl clients -j)
    local count_before=$(echo "$windows_before" | jq 'length')

    # Spawn into special workspace silently
    hyprctl dispatch exec "[float; size $width $height; workspace special:scratchpad silent] $TERMINAL_CMD"

    sleep 0.2

    local windows_after=$(hyprctl clients -j)
    local count_after=$(echo "$windows_after" | jq 'length')

    local new_addr=""

    if [ "$count_after" -gt "$count_before" ]; then
        new_addr=$(comm -13 \
            <(echo "$windows_before" | jq -r '.[].address' | sort) \
            <(echo "$windows_after" | jq -r '.[].address' | sort) \
            | head -1)
    fi

    if [ -z "$new_addr" ] || [ "$new_addr" = "null" ]; then
        new_addr=$(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[-1] | .address')
    fi

    if [ -n "$new_addr" ] && [ "$new_addr" != "null" ]; then
        echo "$new_addr" > "$ADDR_FILE"
        debug_echo "Terminal created with address: $new_addr"

        sleep 0.1

        # Move to current workspace, pin, resize, then animate in
        hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$new_addr"
        hyprctl dispatch pin "address:$new_addr"
        hyprctl dispatch resizewindowpixel "exact $width $height,address:$new_addr" >/dev/null 2>&1
        animate_slide_down "$new_addr" "$target_x" "$target_y" "$width" "$height"

        return 0
    fi

    debug_echo "Failed to get terminal address"
    return 1
}

# Main logic
if terminal_exists; then
    TERMINAL_ADDR=$(get_terminal_address)
    debug_echo "Found existing terminal: $TERMINAL_ADDR"

    if terminal_in_special; then
        debug_echo "Bringing terminal from scratchpad with slide down"

        pos_info=$(calculate_dropdown_position)
        target_x=$(echo $pos_info | cut -d' ' -f1)
        target_y=$(echo $pos_info | cut -d' ' -f2)
        width=$(echo $pos_info | cut -d' ' -f3)
        height=$(echo $pos_info | cut -d' ' -f4)

        # Move to current workspace first, then animate down
        hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$TERMINAL_ADDR"
        hyprctl dispatch pin "address:$TERMINAL_ADDR"
        hyprctl dispatch resizewindowpixel "exact $width $height,address:$TERMINAL_ADDR" >/dev/null 2>&1
        animate_slide_down "$TERMINAL_ADDR" "$target_x" "$target_y" "$width" "$height"
        hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"

    else
        debug_echo "Hiding terminal to scratchpad with slide up"

        geometry=$(get_window_geometry "$TERMINAL_ADDR")
        if [ -n "$geometry" ]; then
            curr_x=$(echo $geometry | cut -d' ' -f1)
            curr_y=$(echo $geometry | cut -d' ' -f2)
            curr_width=$(echo $geometry | cut -d' ' -f3)
            curr_height=$(echo $geometry | cut -d' ' -f4)

            debug_echo "Current geometry: ${curr_x},${curr_y} ${curr_width}x${curr_height}"

            # KEY FIX for v0.53.1+:
            # Move to scratchpad FIRST, THEN animate the pixel movement.
            # Old order was: animate pixels → then move workspace.
            # The workspace transition was resetting window position mid-animation,
            # causing the bounce-back artifact (slides up, snaps back, disappears).
            # By moving first (which is visually instant since the window is pinned),
            # the subsequent pixel animation runs without any workspace interference.
            hyprctl dispatch pin "address:$TERMINAL_ADDR"         # unpin (toggle off)
            hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$TERMINAL_ADDR"
            sleep 0.05  # let the workspace move settle

            animate_slide_up "$TERMINAL_ADDR" "$curr_x" "$curr_y" "$curr_width" "$curr_height"
        else
            debug_echo "Could not get geometry, hiding without animation"
            hyprctl dispatch pin "address:$TERMINAL_ADDR"
            hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$TERMINAL_ADDR"
        fi
    fi

else
    debug_echo "No existing terminal found, creating new one"
    if spawn_terminal; then
        TERMINAL_ADDR=$(get_terminal_address)
        if [ -n "$TERMINAL_ADDR" ]; then
            hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"
        fi
    fi
fi