#!/bin/bash

DIR=$HOME/Pictures/wallpapers/
PICS=($(find ${DIR} -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \)))
RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}

# swww query || swww init
swww query || swww-daemon --format xrgb
swww img ${RANDOMPICS} --transition-fps 60 --transition-type any --transition-duration 3

# exec $HOME/.config/hypr/scripts/PywalSwww.sh &
sleep 1
exec $HOME/.config/hypr/scripts/Refresh.sh

# mpvpaper -p -o "--loop --no-audio --panscan=1 --speed=1.0" '*' /home/itachi/Pictures/hollow-knight-echo-of-shadows.3840x2160.mp4