#!/bin/bash
#

main() {
	local play_menu="Play now"
	local search_menu="Search"
	local end_menu="End"

	local option=$(echo -e "$play_menu\n$search_menu\n$end_menu" | rofi -show-icons -dmenu -p "Youtube: ")

	case $option in
	"Play now")
		local title=$(rofi -show-icons -dmenu -p "Play now: ")
		mpv --no-resume-playback --geometry=+50%-25 ytdl://ytsearch:"$title"
		;;
	"Search")
		local search=$(rofi -show-icons -dmenu -p "Search: ")
		local play=$(yt-dlp --get-title "ytsearch10:$search" --no-warnings --flat-playlist --skip-download --quiet --no-check-certificate --geo-bypass | rofi -show-icons -dmenu -p "Play: ")
		mpv --no-resume-playback ytdl://ytsearch:"$play"
		;;
	"End")
		pkill -f "mpv"
		;;
	*) ;;
	esac
}

main