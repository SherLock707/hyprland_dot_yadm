#!/bin/bash


DIR="$HOME/.config"
rofi_cmd="rofi -theme $DIR/rofi/test-powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')
#bat_health=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | rg capacity | awk '{print$2}')

# Options
Shutdown=""
Reboot=""
Lock=""
Suspend=""
Logout=""

options="$Shutdown\n$Reboot\n$Lock\n$Suspend\n$Logout"


# Show menu
chosen="$(echo -e "$options" | $rofi_cmd -p "Uptime <=> $uptime" -dmenu)"

# Command for specific choices
case $chosen in
"$Shutdown")
	systemctl poweroff
;;
"$Reboot")
	systemctl reboot
;;
"$Suspend")
	systemctl suspend
;;
"$Lock")
  hyprlock
;;
"$Logout")
  hyprctl dispatch exit
;;
esac
