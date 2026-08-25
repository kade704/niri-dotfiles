#!/bin/bash
set -euo pipefail

info() { printf '\n\033[1;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\n\033[1;32m[DONE]\033[0m %s\n' "$1"; }
warning() { printf '\n\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\n\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

# Root 실행 방지
if [ "${EUID}" -eq 0 ]; then
    error "Do not run this script as root."
    exit 1
fi

# sudo 권한 타임아웃 방지 (스크립트 실행 동안 sudo 유효 유지)
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

info "Installing base packages..."
sudo pacman -S --needed --noconfirm git base-devel
success "Base packages installed."

# yay 설치 (이미 설치되어 있으면 스킵)
if ! command -v yay &> /dev/null; then
    info "Installing yay..."
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
    (cd "$BUILD_DIR/yay" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
    success "yay installed."
else
    info "yay is already installed. Skipping."
fi

info "Updating system and installing main packages..."
PACKAGES=(
    "niri"
    "gdm"
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "ttf-noto-nerd"
    "eza"
    "fish"
    "foot"
    "fuzzel"
    "mako"
    "swaybg"
    "swaylock-effects"
    "swayidle"
    "wlogout"
    "nautilus"
    "mpv"
    "xdg-desktop-portal-gnome"
    "wlsunset"
)
yay -Syu --needed --noconfirm "${PACKAGES[@]}"
success "Main packages installed."

info "Enabling GDM service..."
sudo systemctl enable gdm.service

info "Switching default shell to Fish..."
FISH_PATH="$(command -v fish)"
if [ "$SHELL" != "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH"
    success "Shell changed to Fish."
else
    info "Fish is already the default shell."
fi

info "Installing dotfiles..."
mkdir -p ~/.config ~/Pictures

if [ -d "configs" ]; then
    cp -rb configs/* ~/.config/
fi
if [ -d "pictures" ]; then
    cp -rb pictures/* ~/Pictures/
fi

# 임시 디렉터리에서 외부 테마 빌드 및 설치
TMP_THEME_DIR=$(mktemp -d)

info "Installing GTK & Icon themes..."
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git "$TMP_THEME_DIR/Graphite-gtk-theme"
sudo "$TMP_THEME_DIR/Graphite-gtk-theme/install.sh" --gdm --color dark

git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$TMP_THEME_DIR/Tela-circle-icon-theme"
"$TMP_THEME_DIR/Tela-circle-icon-theme/install.sh" black

git clone https://github.com/vinceliuice/Graphite-cursors.git "$TMP_THEME_DIR/Graphite-cursors"
"$TMP_THEME_DIR/Graphite-cursors/install.sh"

rm -rf "$TMP_THEME_DIR"
success "Dotfiles and themes installed."

info "Setting up user systemd services..."
mkdir -p ~/.config/systemd/user/
if [ -d "services" ]; then
    cp services/* ~/.config/systemd/user/
    systemctl --user daemon-reload
fi

SERVICES=(
    "mako"
    "swaybg"
    "swayidle"
    "wlsunset"
)

for SERVICE in "${SERVICES[@]}"; do
    systemctl --user add-wants niri.service $SERVICE.service || true
done
success "Services configured."

success "Installation complete!"
read -rp "Do you want to reboot now? [y/N]: " answer
case "$answer" in
    [yY][eE][sS]|[yY])
        sudo reboot
        ;;
    *)
        info "Reboot cancelled."
        ;;
esac
