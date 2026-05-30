#!/usr/bin/env bash

PHONE_NAME="POCO F7"
DEVICE="9f6040691bc544079f3d84a9284d8e67"

BASE="/modules/kdeconnect/devices/$DEVICE"
SERVICE="org.kde.kdeconnect"

# Connected?
CONNECTED=$(qdbus "$SERVICE" "$BASE" \
    org.freedesktop.DBus.Properties.Get \
    org.kde.kdeconnect.device isReachable 2>/dev/null)

if [[ "$CONNECTED" != "true" ]]; then
    printf '%s\n' '{"text":"","alt":"disconnected","tooltip":"POCO F7 disconnected"}'
    exit 0
fi

# Battery info
BATTERY_INFO=$(qdbus "$SERVICE" "$BASE/battery" \
    org.freedesktop.DBus.Properties.GetAll \
    org.kde.kdeconnect.device.battery 2>/dev/null)

BATTERY=$(awk '/charge:/ {print $2}' <<< "$BATTERY_INFO")
CHARGING=$(awk '/isCharging:/ {print $2}' <<< "$BATTERY_INFO")

# Fallbacks
BATTERY=${BATTERY:-0}
CHARGING=${CHARGING:-false}

# Notification count
NOTIFS=$(qdbus "$SERVICE" "$BASE/notifications" \
    org.kde.kdeconnect.device.notifications.activeNotifications 2>/dev/null)

NOTIFS=${NOTIFS:-0}

# State
STATE="normal"

if [[ "$CHARGING" == "true" ]]; then
    STATE="charging"
elif (( BATTERY < 20 )); then
    STATE="low"
fi

# Notification badge
NOTIF_TEXT=""
if (( NOTIFS > 0 )); then
    NOTIF_TEXT=" <big></big><sup><span foreground='#FAA0A0'></span></sup> $NOTIFS"
fi

# Generate valid JSON
jq -nc \
    --arg text "${BATTERY}%${NOTIF_TEXT}" \
    --arg alt "$STATE" \
    --arg tooltip " ${PHONE_NAME}
󱊣 Battery: ${BATTERY}%
 Charging: ${CHARGING}
󰎟 Notifications: ${NOTIFS}" \
    '{
        text: $text,
        alt: $alt,
        tooltip: $tooltip
    }'