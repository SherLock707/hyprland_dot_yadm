#!/bin/bash

DIRECTORY=$(
    cd $(dirname $0) >/dev/null 2>&1
    pwd -P
)
cd "${DIRECTORY}/wallpapers" || exit 1

declare -a wallpapers

for wallpaper in $(
    ls | grep .*\.png
); do
    wallpapers+=("$wallpaper")
done

echo "Choose the main menu theme: "

i=0
for wallpaper in "${wallpapers[@]}"; do
    echo -n "${i}.- "
    echo $(echo -n "${wallpaper::-4}" | sed -r "s/_/ /g")
    i=$(($i + 1))
done

read wallpaper_index

if ! (("$wallpaper_index" < ${#wallpapers[@]} && "$wallpaper_index" >= 0)); then
    echo "Not a valid theme"
    exit 1
fi

wallpaper="${wallpapers[${wallpaper_index}]}"
cp "$wallpaper" "${DIRECTORY}/hollow-grub/wallpaper.png"
echo -n "Changed wallpaper to "
echo $(echo "${wallpaper::-4}" | sed -r "s/_/ /g")
