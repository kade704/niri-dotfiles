#!/bin/bash

CONFIG_DIRS=(
    "niri"
    "waybar"
    "foot"
    "wlogout"
    "fuzzel"
    "mako"
    "fish"
    "swaylock"
    "xdg-desktop-portal"
    "mpv"
)

DEST_DIR=$(dirname "$0")

for DIR in "${CONFIG_DIRS[@]}"; do
    rsync -av --delete "$HOME/.config/$DIR/" "$DEST_DIR/configs/$DIR"
    echo "$DIR Updated."
done
