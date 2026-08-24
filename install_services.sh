#!/bin/bash

SERVICES=(
    "mako"
    "waybar"
    "swaybg"
    "swayidle"
    "wlsunset"
)

cp services/* ~/.config/systemd/user/

for SERVICE in "${SERVICES[@]}"; do
    systemctl --user add-wants niri.service $SERVICE.service
done
