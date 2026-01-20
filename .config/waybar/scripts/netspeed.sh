#!/bin/bash

iface=$(ip route | awk '/default/ {print $5; exit}')

if [ -z "$iface" ]; then
    echo '{"text": "Disconnected", "class": "disconnected"}'
    exit 0
fi

get_bytes() {
    grep "$iface" /proc/net/dev | awk '{print $2, $10}'
}

read rx_prev tx_prev <<< $(get_bytes)

while true; do
    sleep 1

    read rx_curr tx_curr <<< $(get_bytes)

    rx_diff=$((rx_curr - rx_prev))
    tx_diff=$((tx_curr - tx_prev))

    rx_mb=$(awk "BEGIN {printf \"%.2f\", $rx_diff / 1048576}")
    tx_mb=$(awk "BEGIN {printf \"%.2f\", $tx_diff / 1048576}")

    echo "{\"text\": \"   ${rx_mb}M/s      ${tx_mb}M/s\", \"tooltip\": \"Interface: $iface\", \"class\": \"connected\"}"
    rx_prev=$rx_curr
    tx_prev=$tx_curr
done
