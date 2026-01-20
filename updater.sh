#!/bin/bash

SOURCE_DIRS=(
    ".config/niri"
    ".config/waybar"
    ".config/foot"
    ".config/wlogout"
    ".config/fuzzel"
    ".config/mako"
    ".config/fish"
    ".config/swaylock"
)

DEST_DIR=$(dirname "$0")

for DIR in "${SOURCE_DIRS[@]}"; do
    rsync -av --delete "$HOME/$DIR" "$DEST_DIR/.config/"
    echo "$DIR Updated."
done
