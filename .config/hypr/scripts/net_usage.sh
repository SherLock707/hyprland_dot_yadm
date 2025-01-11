#!/bin/bash

interface="enp5s0"

# Extract RX and TX bytes
rx_bytes=$(awk -v iface="$interface:" '$1 == iface {print $2}' /proc/net/dev)
tx_bytes=$(awk -v iface="$interface:" '$1 == iface {print $10}' /proc/net/dev)

# Convert to human-readable format
rx_human=$(numfmt --to=iec $rx_bytes)
tx_human=$(numfmt --to=iec $tx_bytes)

# Check internet connectivity using ping
if ping -W 0.1 -c 1 1.1.1.1 > /dev/null 2>&1; then
    alt_status="success"
else
    alt_status="fail"
fi

# Generate JSON output
echo -e "{\"alt\": \"${alt_status}\", \"tooltip\": \"Interface: ${interface}\\\nReceived: ${rx_human}\\\nTransmitted: ${tx_human}\"}"
