#!/bin/bash

# ProtonVPN Waybar module
# left click → toggle
# prints JSON status for Waybar

INTERFACE="pvpnksintrf0"

is_connected() {
    ip link show "$INTERFACE" >/dev/null 2>&1
}

toggle_vpn() {
    if is_connected; then
        protonvpn disconnect >/dev/null 2>&1
    else
        protonvpn connect >/dev/null 2>&1
    fi
}

case "$1" in
    toggle)
        toggle_vpn
        ;;
    *)
        if is_connected; then
            echo '{"text":"<big>  </big>","class":"active","tooltip":"VPN Connected"}'
        else
            echo '{"text":"<big>  </big>","class":"inactive","tooltip":"VPN Disconnected"}'
        fi
        ;;
esac
