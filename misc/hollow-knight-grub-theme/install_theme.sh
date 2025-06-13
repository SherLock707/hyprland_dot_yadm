#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "This script must be run as root"
    exit
fi

SCRIPT_DIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

# check if the grub folder is called grub/ or grub2/
if [ -d /boot/grub ]; then
    grub_path="/boot/grub"
elif [ -d /boot/grub2 ]; then
    grub_path="/boot/grub2"
else
    echo "Can't find a /boot/grub or /boot/grub2 folder. Exiting."
    exit
fi
theme_path="$grub_path/themes/hollow-grub"

## Prompts

# Choosing a background, comment this out if it's annoying
read -p "[?] Do you want to choose a specific background? [y/N] " -en 1 choose_bg
if [[ "$choose_bg" =~ y|Y ]]; then
    echo "[INFO] Choosing a background from ./wallpapers/"
    $SCRIPT_DIR/theme_selector.sh
else
    echo "[INFO] [Skipping] Choosing a background"
fi

read -p "[?] Copy/Update the theme to '$theme_path'? [Y/n] " -en 1 copy_theme
if [[ "$copy_theme" =~ y|Y || -z "$copy_theme" ]]; then
    echo "[INFO] => Copying the theme files to boot partition:"
    # copy recursive, update, verbose
    cd $SCRIPT_DIR && cp -ruv ./hollow-grub $grub_path/themes/ | awk '$0 !~ /skipped/ { print "\t"$0 }'
else
    echo "[INFO] [Skipping] Copying the theme files to boot partition"
fi

echo
echo "======= Done! ======="
echo "[YEAH] Make sure to add/change this line in /etc/default/grub :"
echo
echo -e "    GRUB_THEME=$theme_path/theme.txt"
echo
echo
