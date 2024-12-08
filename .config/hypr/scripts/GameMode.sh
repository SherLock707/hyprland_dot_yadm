#!/bin/bash
# Game Mode. Turning off all animations

notif="$HOME/.config/dunst/images/bell.png"
SCRIPTSDIR="$HOME/.config/hypr/scripts"


HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
		keyword decoration:blur:passes 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"001
	
	hyprctl keyword "windowrule opacity 1 override 1 override 1 override, ^(.*)$"
    swww kill 
    notify-send -e -u low -i "$notif" " GameMode enabled!"
    exit
else
	swww-daemon --format xrgb && swww img "$HOME/.config/rofi/.current_wallpaper" &
	sleep 0.1
	${SCRIPTSDIR}/PywalSwww.sh
	sleep 0.5
	${SCRIPTSDIR}/Refresh.sh	 
    notify-send -e -u normal -i "$notif" "GameMode disabled."
    exit
fi
hyprctl reload