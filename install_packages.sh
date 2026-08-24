#!/bin/bash

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git

cd yay
makepkg -si

cd ..

PACKAGES=(
    "niri"
    "sddm"
    "noto-fonts"
    "noto-fonts-cjk"
    "ttf-noto-nerd"
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

yay -Syu "${PACKAGES[@]}"

sudo systemctl enable sddm.service
