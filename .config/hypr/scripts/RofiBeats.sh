#!/bin/bash

# Directory for icons
iDIR="$HOME/.config/dunst/icons"

# Note: You can add more options below with the following format:
# ["TITLE"]="link"

# Define menu options as an associative array
declare -A menu_options=(
  ["Green LoFi 💚🎶"]="https://www.youtube.com/playlist?list=PLl2G65bbMeeVj9KSCYoC_5NEx7KB8DeRO"
  ["Lofi Girl ☕️🎶"]="https://play.streamafrica.net/lofiradio"
  ["Ghibli Music 🎻🎶"]="https://youtube.com/playlist?list=PLNi74S754EXbrzw-IzVhpeAaMISNrzfUy&si=rqnXCZU5xoFhxfOl"
  ["SmoothChill 🏖️🎶"]="https://media-ssl.musicradio.com/SmoothChill"
  ["Relaxing Music ☕️🎶"]="https://youtube.com/playlist?list=PLMIbmfP_9vb8BCxRoraJpoo4q1yMFg4CE"
  ["Doja Cat - Agora Hills 💃🎶"]="https://www.youtube.com/playlist?list=PLl2G65bbMeeXLM5xu9lavnk1jbsAIhnr6"
  ["Cannons - Golden cover 💃🎶"]="https://www.youtube.com/watch?v=ZznBYOeDmug"
)

# Function for displaying notifications
notification() {
  # dunstify -u normal -i "$iDIR/music.png" "Playing now: $@"
  notify-send -u low -i "$iDIR/music.png" "Playing now: $@"
}

# Main function
main() {
  choice=$(printf "%s\n" "${!menu_options[@]}" | rofi -dmenu -config ~/.config/rofi/config-rofi-Beats.rasi -i -p "")

  if [ -z "$choice" ]; then
    exit 1
  fi

  link="${menu_options[$choice]}"

  notification "$choice"
  
  # Check if the link is a playlist
  if [[ $link == *playlist* ]]; then
    mpv --shuffle --vid=no "$link"
  else
    mpv "$link"
  fi
}

# Check if an online music process is running and send a notification, otherwise run the main function
# main
# pkill -f "mpv --shuffle --vid=no" && dunstify -u low -i "$iDIR/music.png" "Online Music stopped" || main
pkill mpv && notify-send -u low -i "$iDIR/music.png" "Online Music stopped" || main
# pkill -f http && dunstify -u low -i "$iDIR/music.png" "Online Music stopped" || main
# main
