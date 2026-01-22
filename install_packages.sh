#!/bin/bash

PACKAGES=(
    "niri"
    "fish"
    "foot"
    "fuzzel"
    "mako"
    "swaylock"
    "swayidle"
    "waybar"
    "wlogout"
    "nautilus"
    "mpv"
    "xdg-desktop-portal-gnome"
    "wlsunset"
)

sudo pacman -Syu "${PACKAGES[@]}"
