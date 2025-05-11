#!/bin/bash

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"

# notify and view screenshot
notify_cmd_shot="notify-send -t 10000 -A action1=Open -A action2=Delete -h string:x-canonical-private-synchronous:shot-notify -u low -i ${dir}/${file}"
notify_view() {
	# ${notify_cmd_shot} "Copied to clipboard."
	if [[ -e "$dir/$file" ]]; then
		resp=$(timeout 10 ${notify_cmd_shot} " $file ")
		echo "$resp"
		case "$resp" in
			action1)
				xdg-open "${dir}/${file}" &
				;;
			action2)
				rm "${dir}/${file}" &
				;;
		esac
	else
		${notify_cmd_shot} " Screenshot Deleted."
	fi
}

# countdown
countdown() {
	for sec in $(seq $1 -1 1); do
		notify-send -h string:x-canonical-private-synchronous:shot-notify -t 1000 -i "$iDIR"/timer.png "Taking shot in : $sec"
		sleep 1
	done
}

# take shots
shotnow() {
	cd ${dir} && grim - | tee "$file" | wl-copy
	# sleep 1
	notify_view
}

# take shots
shothush() {
	cd ${dir} && grim - | tee "$file" | wl-copy
}

shot5() {
	countdown '5'
	sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
	sleep 1
	notify_view
	
}

shot10() {
	countdown '10'
	sleep 1 && cd ${dir} && grim - | tee "$file" | wl-copy
	notify_view
}

shotwin() {
	w_pos=$(hyprctl activewindow | grep 'at:' | cut -d':' -f2 | tr -d ' ' | tail -n1)
	w_size=$(hyprctl activewindow | grep 'size:' | cut -d':' -f2 | tr -d ' ' | tail -n1 | sed s/,/x/g)
	cd ${dir} && grim -g "$w_pos $w_size" - | tee "$file" | wl-copy
	notify_view
}

shotarea() {
	cd ${dir} && grim -g "$(slurp && sleep 0.1)" - | tee "$file" | wl-copy
	notify_view
}

if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

if [[ "$1" == "--now" ]]; then
	shotnow
elif [[ "$1" == "--in5" ]]; then
	shot5
elif [[ "$1" == "--in10" ]]; then
	shot10
elif [[ "$1" == "--win" ]]; then
	shotwin
elif [[ "$1" == "--area" ]]; then
	shotarea
elif [[ "$1" == "--hush" ]]; then
	shothush
else
	echo -e "Available Options : --now --in5 --in10 --win --area"
fi

exit 0
