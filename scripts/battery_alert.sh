#!/bin/bash
while true; do
    battery=$(cat /sys/class/power_supply/BAT0/capacity)
    if [ "$battery" -le 15 ]; then
        notify-send "Battery low! $battery% remaining."
    fi
    sleep 300
done
