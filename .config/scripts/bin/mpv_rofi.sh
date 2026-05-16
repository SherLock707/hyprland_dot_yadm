#!/bin/bash
URL=$(rofi -dmenu -p "Enter URL for MPV")

# Run mpv only if URL is provided
if [[ -n "$URL" ]]; then
  mpv "$URL"
fi
