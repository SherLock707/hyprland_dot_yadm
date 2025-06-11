#!/bin/bash

iDIR="$HOME/.config/swaync/assets"
notification_timeout=1000
cache_file="/tmp/brightness_cache_$USER"
bus=7

# Get brightness and cache it if not already
get_backlight() {
	if [[ ! -s "$cache_file" ]]; then
		brightness=$(ddcutil --brief --bus "$bus" getvcp 10 | awk '{print $4}')
		echo "$brightness" > "$cache_file"
	else
		brightness=$(<"$cache_file")
	fi
	echo "$brightness"
}

get_backlight_icon() {
	# Always get fresh brightness value for display
	brightness=$(ddcutil --brief --bus "$bus" getvcp 10 | awk '{print $4}')
	
	# Return appropriate icon based on brightness level
	if [[ $brightness -le 20 ]]; then
		icon="󰃞"
	elif [[ $brightness -le 50 ]]; then
		icon="󰃟"
	else
		icon="󰃠"
	fi
	
	# Return Waybar module JSON
	printf '{"text": "%s", "tooltip": "Brightness: %d%%", "percentage": %d}\n' "$icon" "$brightness" "$brightness"
}

# Get appropriate icon
get_icon() {
	current=$(get_backlight)
	if   [ "$current" -le 20 ]; then
		icon="$iDIR/brightness-20.png"
	elif [ "$current" -le 40 ]; then
		icon="$iDIR/brightness-40.png"
	elif [ "$current" -le 60 ]; then
		icon="$iDIR/brightness-60.png"
	elif [ "$current" -le 80 ]; then
		icon="$iDIR/brightness-80.png"
	else
		icon="$iDIR/brightness-100.png"
	fi
}

# Show notification
notify_user() {
	notify-send -e -a brightness -h string:x-canonical-private-synchronous:brightness_notif -h boolean:SWAYNC_BYPASS_DND:true \
		-h int:value:$current -u low -i "$icon" "Brightness : $current%"
}

# Change brightness with computed delta
change_backlight() {
	current=$(get_backlight)
	current=${current//[^0-9]/}  # Strip non-numeric

	if [[ "$1" == "- 10" ]]; then
		new=$((current - 10))
	else
		new=$((current + 10))
	fi

	# Clamp between 0–100
	(( new > 100 )) && new=100
	(( new < 0 )) && new=0

	# Apply and update cache
	ddcutil --noconfig --noverify --bus "$bus" --sleep-multiplier 0.03 setvcp 10 $1
	echo "$new" > "$cache_file"

	get_icon
	notify_user
}

direct_set(){
	ddcutil --noconfig --noverify --bus "$bus" --sleep-multiplier 0.03 setvcp 10 $1
}

# Main control logic
case "$1" in
	"--get")
		get_backlight
		;;
	"--inc")
		change_backlight "+ 10"
		;;
	"--dec")
		change_backlight "- 10"
		;;
	"--direct")
		direct_set $2
		;;
	*)
		get_backlight_icon
		;;
esac