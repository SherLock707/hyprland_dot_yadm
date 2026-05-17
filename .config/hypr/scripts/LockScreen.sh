#!/bin/bash

if [[ "$1" == "--suspend" ]]; then
    systemctl suspend
else
    hyprlock -q
fi