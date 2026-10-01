#!/usr/bin/env bash
#
# install.sh - Universal installer for macOS Dock Plasma 6 widget
# Supports automated dependency installation and build for major Linux distros
#

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

info() {
    echo -e "${CYAN}${BOLD}[INFO]${RESET} $*"
}

success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${RESET} $*"
}

warn() {
    echo -e "${YELLOW}${BOLD}[WARNING]${RESET} $*"
}

error() {
    echo -e "${RED}${BOLD}[ERROR]${RESET} $*"
}

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BOLD}=========================================${RESET}"
echo -e "${BOLD}       macOS Dock for KDE Plasma 6       ${RESET}"
echo -e "${BOLD}=========================================${RESET}"
echo ""

# 1. Detect Linux Distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE=""
    fi
}

detect_distro
info "Detected OS: ${DISTRO_ID} (${DISTRO_LIKE:-standalone})"

# 2. Check and Install Dependencies
install_dependencies() {
    info "Checking required build dependencies..."
    
    local NEED_DEPS=0
    if ! command -v cmake >/dev/null 2>&1 || ! command -v g++ >/dev/null 2>&1; then
        NEED_DEPS=1
    fi

    if [ "$NEED_DEPS" -eq 1 ] || [ "${1:-}" = "--deps" ]; then
        info "Installing build dependencies..."
        if [[ "$DISTRO_ID" =~ ^(fedora|rhel|centos)$ ]] || [[ "$DISTRO_LIKE" =~ fedora ]]; then
            sudo dnf install -y --setopt=install_weak_deps=False --allowerasing \
                cmake \
                gcc-c++ \
                extra-cmake-modules \
                qt6-qtbase-devel \
                qt6-qtdeclarative-devel \
                kf6-kwindowsystem-devel
        elif [[ "$DISTRO_ID" =~ ^(arch|manjaro|endeavouros)$ ]] || [[ "$DISTRO_LIKE" =~ arch ]]; then
            sudo pacman -S --needed --noconfirm \
                cmake \
                gcc \
                extra-cmake-modules \
                qt6-base \
                qt6-declarative \
                kwindowsystem
        elif [[ "$DISTRO_ID" =~ ^(ubuntu|debian|pop|linuxmint)$ ]] || [[ "$DISTRO_LIKE" =~ (ubuntu|debian) ]]; then
            sudo apt update
            sudo apt install -y \
                cmake \
                build-essential \
                extra-cmake-modules \
                qt6-base-dev \
                qt6-declarative-dev \
                libkf6windowsystem-dev
        elif [[ "$DISTRO_ID" =~ ^(opensuse|suse)$ ]] || [[ "$DISTRO_LIKE" =~ suse ]]; then
            sudo zypper install -y \
                cmake \
                gcc-c++ \
                extra-cmake-modules \
                qt6-base-devel \
                qt6-declarative-devel \
                kf6-kwindowsystem-devel
        else
            warn "Could not automatically determine package manager for ${DISTRO_ID}."
            warn "Please ensure cmake, extra-cmake-modules, Qt6 dev, and KF6 WindowSystem dev packages are installed."
        fi
    fi
}

install_dependencies

# 3. Build C++ Blur Plugin & Plasmoid
info "Configuring build with CMake..."
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

info "Building components..."
cmake --build build -j"$(nproc 2>/dev/null || echo 2)"

# 4. Install
info "Installing to system (requires sudo for /usr/lib64 and /usr/share)..."
sudo cmake --install build

# 5. Also install icon into user directory as backup
USER_ICON_DIR="${HOME}/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$USER_ICON_DIR"
cp "assets/logo.png" "${USER_ICON_DIR}/com.github.mattanis.macosdock.png"
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -q -t -f "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
fi

success "Installation completed successfully!"
echo ""

# 6. Prompt to restart Plasma Shell
if systemctl --user is-active --quiet plasma-plasmashell; then
    read -rp "Would you like to restart Plasma Shell now to load the new widget and icon? [y/N]: " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            info "Restarting plasma-plasmashell..."
            systemctl --user restart plasma-plasmashell
            success "Plasma Shell restarted."
            ;;
        *)
            info "You can restart Plasma later with: systemctl --user restart plasma-plasmashell"
            ;;
    esac
else
    info "Plasma shell is not running under systemd. Restart it manually if needed."
fi

echo ""
success "Done! You can now add 'macOS Dock' from your Plasma Widget Explorer."
