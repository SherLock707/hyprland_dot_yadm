#!/bin/bash

action=$(dunstctl action)
rofi -dmenu -p "Choose action:" <<< "$action"
