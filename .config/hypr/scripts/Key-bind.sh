#!/usr/bin/env bash

if pidof rofi > /dev/null; then
    pkill rofi
    exit
fi

KEYBINDS=$(
    hyprctl binds -j | jq -r '

    def getbit($pos; $n):
        ((($n / (($pos | exp2))) | floor) % 2);

    def mods($m):
        (if getbit(6; $m) == 1 then " + " else "" end) +
        (if getbit(0; $m) == 1 then "SHIFT + " else "" end) +
        (if getbit(2; $m) == 1 then "CTRL + " else "" end) +
        (if getbit(3; $m) == 1 then "ALT + " else "" end);

    .[]
    | select(.has_description == true)
    | [
        .description,
        ("  " + mods(.modmask) + .key)
      ]
    | @tsv
    ' | while IFS=$'\t' read -r desc key; do
        printf "%-35s %s\n" "$desc" "$key"
    done
)

if [[ -z "$KEYBINDS" ]]; then
    echo "No keybinds found."
    exit 1
fi

echo "$KEYBINDS" \
    | rofi \
        -dmenu \
        -i \
        -matching fuzzy \
        -p "Keybinds" \
        -config ~/.config/rofi/config-keybinds.rasi