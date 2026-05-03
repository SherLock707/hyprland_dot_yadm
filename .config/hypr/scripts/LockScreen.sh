#!/bin/bash

# lock function
lock() {
    hyprlock -q --immediate &
}

if [[ "$1" == "--suspend" ]]; then
    # run lock in background so it doesn't block
    hyprlock -q --immediate &
    
    # give it a moment to actually lock
    sleep 0.5
    
    systemctl suspend
else
    # default behavior (just lock)
    lock
fi