#!/usr/bin/env bash

PHONE_NAME="POCO F7"

DEVICE=$(kdeconnect-cli -a --id-name-only 2>/dev/null | \
    awk -v phone="$PHONE_NAME" '
    $0 ~ phone {
        print $1
        exit
    }')

if [[ -z "$DEVICE" ]]; then
    echo '{"text":"disconnected","tooltip":"POCO F7 disconnected"}'
    exit 0
fi

BATTERY_PATH="/modules/kdeconnect/devices/$DEVICE/battery"
DBUS_SERVICE="org.kde.kdeconnect"
DBUS_IFACE="org.kde.kdeconnect.device.battery"

BATTERY=$(qdbus "$DBUS_SERVICE" "$BATTERY_PATH" \
    org.freedesktop.DBus.Properties.Get \
    "$DBUS_IFACE" charge)

CHARGING=$(qdbus "$DBUS_SERVICE" "$BATTERY_PATH" \
    org.freedesktop.DBus.Properties.Get \
    "$DBUS_IFACE" isCharging)

STATE="normal"

if [[ "$CHARGING" == "true" ]]; then
    STATE="charging"
elif (( BATTERY < 20 )); then
    STATE="low"
fi

echo "{\"text\":\"${BATTERY}%\",\"alt\":\"$STATE\",\"tooltip\":\"POCO F7 | ${BATTERY}% | Charging: $CHARGING\"}"