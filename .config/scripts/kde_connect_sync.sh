#!/bin/bash

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
RESET='\e[0m'

# Divider function
divider() {
    echo -e "${BLUE}-------------------------------------------------${RESET}"
}

divider
echo -e "${YELLOW}🔍 Checking for KDE Connect device...${RESET}"
DEVICE_ID=$(kdeconnect-cli -a --id-only)

if [[ -z "$DEVICE_ID" ]]; then
    echo -e "${RED}❌ No connected KDE Connect devices found.${RESET}"
    notify-send "KDE Connect" "No connected devices found."
    exit 1
fi

echo -e "${GREEN}✅ Detected Device ID: ${DEVICE_ID}${RESET}"
divider

MOUNT_PATH="/run/user/1000/$DEVICE_ID/"

if [[ -d "$MOUNT_PATH" ]]; then
    echo -e "${GREEN}🔗 Device is already mounted at: $MOUNT_PATH${RESET}"
else
    echo -e "${YELLOW}📌 Mounting KDE Connect SFTP...${RESET}"
    qdbus-qt5 org.kde.kdeconnect /modules/kdeconnect/devices/"$DEVICE_ID"/sftp mountAndWait
    sleep 2

    if [[ ! -d "$MOUNT_PATH" ]]; then
        echo -e "${RED}❌ Failed to mount device.${RESET}"
        notify-send "KDE Connect" "Failed to mount device."
        exit 1
    fi
    echo -e "${GREEN}✅ Mounted successfully at: $MOUNT_PATH${RESET}"
fi
divider

KDE_CONNECT_PATH="$MOUNT_PATH/KDE_CONNECT"
if [[ ! -d "$KDE_CONNECT_PATH" ]]; then
    echo -e "${RED}❌ KDE_CONNECT folder not found.${RESET}"
    notify-send "KDE Connect" "KDE_CONNECT folder not found."
    exit 1
fi
echo -e "${GREEN}📂 KDE_CONNECT folder found.${RESET}"

VAULT_PATH="$KDE_CONNECT_PATH/obsidian_vault"
BKUP_PATH="$KDE_CONNECT_PATH/obsidian_vault_bkup"

# if [[ -d "$VAULT_PATH" ]]; then
#     echo -e "${YELLOW}🔄 Backing up existing Obsidian vault on device...${RESET}"
#     rm -rf "$BKUP_PATH"
#     mv "$VAULT_PATH" "$BKUP_PATH"
#     echo -e "${GREEN}✅ Backup created: obsidian_vault_bkup${RESET}"
# else
#     echo -e "${YELLOW}📁 No existing Obsidian vault found. Proceeding with sync.${RESET}"
# fi

divider
echo -e "${YELLOW}🚀 Syncing local Obsidian vault to remote...${RESET}"

# Rsync from local to remote (excluding dotfiles)
RSYNC_OUTPUT=$(rsync -a --inplace --ignore-errors --exclude='.*' ~/obsidian_vault/ "$VAULT_PATH/" 2>&1)

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Sync complete!${RESET}"
else
    echo -e "${RED}❌ Sync failed!${RESET}"
    notify-send "KDE Connect" "Obsidian Vault Sync Failed!"
    exit 1
fi
divider

# echo -e "${YELLOW}🔄 Syncing new files from remote back to local...${RESET}"

# # Rsync from remote back to local (only if the file does not exist)
# RSYNC_REVERSE=$(rsync -a -u --backup --suffix=_bkup --exclude='.*' "$VAULT_PATH/" ~/obsidian_vault/ 2>&1)

# if [[ $? -eq 0 ]]; then
#     echo -e "${GREEN}✅ Reverse sync complete!${RESET}"
# else
#     echo -e "${RED}❌ Reverse sync encountered errors.${RESET}"
# fi

# divider
# echo -e "${BLUE}📊 Sync Summary:${RESET}"
# echo "$RSYNC_OUTPUT" | grep -E 'Number of|Total file size|sent|received'
# echo "$RSYNC_REVERSE" | grep -E 'Number of|Total file size|sent|received'

echo -e "${YELLOW}🔄 Checking for new files and directories in remote vault...${RESET}"

# Step 1: Create missing directories first
find "$VAULT_PATH" -type d ! -name ".*" | while read -r dir; do
    rel_path="${dir#$VAULT_PATH/}"  # Remove base path prefix
    src_dir="$HOME/obsidian_vault/$rel_path"

    if [[ ! -d "$src_dir" ]]; then
        mkdir -p "$src_dir"
        echo -e "${GREEN}📁 Created missing directory: $rel_path${RESET}"
    fi
done

# Step 2: Copy missing files
find "$VAULT_PATH" -type f ! -name ".*" | while read -r file; do
    rel_path="${file#$VAULT_PATH/}"  # Remove base path prefix
    src_file="$HOME/obsidian_vault/$rel_path"

    if [[ ! -e "$src_file" ]]; then
        cp "$file" "$src_file"
        echo -e "${GREEN}✅ Copied new file: $rel_path${RESET}"
    fi
done

divider
echo -e "${GREEN}✅ Reverse sync complete!${RESET}"


notify-send "KDE Connect" "Obsidian Vault Sync Completed."
