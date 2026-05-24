#!/usr/bin/env bash

PHONE_NAME="POCO F7"
DEVICE="9f6040691bc544079f3d84a9284d8e67"

BASE="/modules/kdeconnect/devices/$DEVICE"
SERVICE="org.kde.kdeconnect"

# Connected?
CONNECTED=$(qdbus "$SERVICE" "$BASE" \
org.freedesktop.DBus.Properties.Get \
org.kde.kdeconnect.device isReachable 2>/dev/null)

[[ "$CONNECTED" != "true" ]] && {
    echo '{"text":"","alt":"disconnected","tooltip":"POCO F7 disconnected"}'
    exit 0
}

# Battery properties in one call
BATTERY_INFO=$(qdbus "$SERVICE" "$BASE/battery" \
org.freedesktop.DBus.Properties.GetAll \
org.kde.kdeconnect.device.battery)

BATTERY=$(awk '/charge:/ {print $2}' <<< "$BATTERY_INFO")
CHARGING=$(awk '/isCharging:/ {print $2}' <<< "$BATTERY_INFO")

# Notification count
NOTIFS=$(qdbus "$SERVICE" "$BASE/notifications" \
org.kde.kdeconnect.device.notifications.activeNotifications 2>/dev/null)

NOTIFS=${NOTIFS:-0}

# State
STATE="normal"

[[ "$CHARGING" == "true" ]] && STATE="charging"
(( BATTERY < 20 && CHARGING != "true" )) && STATE="low"

# Notification badge
NOTIF_TEXT=""
(( NOTIFS > 0 )) && \
NOTIF_TEXT=" <big></big><sup><span foreground='#FAA0A0'></span></sup> $NOTIFS"

printf '{"text":"%s%%%s","alt":"%s","tooltip":" %s\\n󱊣 Battery: %s%%\\n Charging: %s\\n󰎟 Notifications: %s"}\n' \
"$BATTERY" \
"$NOTIF_TEXT" \
"$STATE" \
"$PHONE_NAME" \
"$BATTERY" \
"$CHARGING" \
"$NOTIFS"