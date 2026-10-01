#!/usr/bin/env bash
#
# install.sh - Installer for macOS Dock Plasma 6 widget
# Supports dependency installation and build for major Linux distros
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

usage() {
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --install-deps   Install build dependencies before building"
    echo "  --uninstall      Remove the widget from the system"
    echo "  --help, -h       Show this help message"
    echo ""
}

# Parse arguments
INSTALL_DEPS=0
UNINSTALL=0

for arg in "$@"; do
    case "$arg" in
        --install-deps)
            INSTALL_DEPS=1
            ;;
        --uninstall)
            UNINSTALL=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $arg"
            usage
            exit 1
            ;;
    esac
done

# Warn if running as root (HOME would resolve to /root)
if [ "$(id -u)" -eq 0 ]; then
    warn "Running as root is not recommended. User icon will be installed to /root."
    warn "Run as a normal user instead (sudo is used only where needed)."
    read -rp "Continue anyway? [y/N]: " root_choice
    case "$root_choice" in
        [yY][eE][sS]|[yY]) ;;
        *) info "Aborted."; exit 1 ;;
    esac
fi

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

# Handle uninstall
if [ "$UNINSTALL" -eq 1 ]; then
    info "Uninstalling macOS Dock widget..."

    # Remove installed files via CMake's install manifest
    MANIFEST_FOUND=0
    if [ -f build/install_manifest.txt ]; then
        MANIFEST_FOUND=1
        info "Removing installed files..."
        sudo xargs -d '\n' rm -f < build/install_manifest.txt
    else
        warn "No build/install_manifest.txt found — cannot determine installed system files."
        warn "You may need to remove system files manually."
    fi

    # Remove user icon
    USER_ICON_FILE="${HOME}/.local/share/icons/hicolor/256x256/apps/com.github.mattanis.macosdock.png"
    if [ -f "$USER_ICON_FILE" ]; then
        rm -f "$USER_ICON_FILE"
        info "Removed user icon."
    fi

    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
    fi

    # Only remove build directory after everything else succeeded
    if [ -d build ]; then
        rm -rf build
        info "Removed build directory."
    fi

    if [ "$MANIFEST_FOUND" -eq 1 ]; then
        success "Uninstall completed (some empty directories may remain)."
    else
        warn "Partial uninstall: user icon and build directory cleaned, but system files could not be removed."
    fi

    info "You may need to restart Plasma Shell."
    exit 0
fi

# 2. Install Dependencies (only when --install-deps is passed)
install_dependencies() {
    if [ "$INSTALL_DEPS" -eq 0 ]; then
        return
    fi

    info "Installing build dependencies..."
    if [[ "$DISTRO_ID" =~ ^(fedora|rhel|centos)$ ]] || [[ "$DISTRO_LIKE" =~ fedora ]]; then
        sudo dnf install -y --setopt=install_weak_deps=False \
            cmake \
            gcc-c++ \
            extra-cmake-modules \
            qt6-qtbase-devel \
            qt6-qtdeclarative-devel \
            kf6-kwindowsystem-devel \
            libplasma-devel
    elif [[ "$DISTRO_ID" =~ ^(arch|manjaro|endeavouros)$ ]] || [[ "$DISTRO_LIKE" =~ arch ]]; then
        sudo pacman -S --needed --noconfirm \
            cmake \
            gcc \
            extra-cmake-modules \
            qt6-base \
            qt6-declarative \
            kwindowsystem \
            libplasma
    elif [[ "$DISTRO_ID" =~ ^(ubuntu|debian|pop|linuxmint)$ ]] || [[ "$DISTRO_LIKE" =~ (ubuntu|debian) ]]; then
        sudo apt update
        sudo apt install -y \
            cmake \
            build-essential \
            extra-cmake-modules \
            qt6-base-dev \
            qt6-declarative-dev \
            libkf6windowsystem-dev \
            libplasma-dev
    elif [[ "$DISTRO_ID" =~ ^(opensuse|suse) ]] || [[ "$DISTRO_LIKE" =~ suse ]]; then
        sudo zypper install -y \
            cmake \
            gcc-c++ \
            extra-cmake-modules \
            qt6-base-devel \
            qt6-declarative-devel \
            kf6-kwindowsystem-devel \
            libplasma6-devel
    else
        warn "Could not automatically determine package manager for ${DISTRO_ID}."
        warn "Please ensure cmake, extra-cmake-modules, Qt6 dev, KF6 WindowSystem dev,"
        warn "and Plasma framework dev packages are installed."
    fi
}

# Print required deps if not auto-installing
print_dependency_hint() {
    if [ "$INSTALL_DEPS" -eq 1 ]; then
        return
    fi

    info "If the build fails due to missing dependencies, re-run with --install-deps"
    info "or install them manually:"

    if [[ "$DISTRO_ID" =~ ^(fedora|rhel|centos)$ ]] || [[ "$DISTRO_LIKE" =~ fedora ]]; then
        echo "  sudo dnf install cmake gcc-c++ extra-cmake-modules qt6-qtbase-devel qt6-qtdeclarative-devel kf6-kwindowsystem-devel libplasma-devel"
    elif [[ "$DISTRO_ID" =~ ^(arch|manjaro|endeavouros)$ ]] || [[ "$DISTRO_LIKE" =~ arch ]]; then
        echo "  sudo pacman -S --needed cmake gcc extra-cmake-modules qt6-base qt6-declarative kwindowsystem libplasma"
    elif [[ "$DISTRO_ID" =~ ^(ubuntu|debian|pop|linuxmint)$ ]] || [[ "$DISTRO_LIKE" =~ (ubuntu|debian) ]]; then
        echo "  sudo apt install cmake build-essential extra-cmake-modules qt6-base-dev qt6-declarative-dev libkf6windowsystem-dev libplasma-dev"
    elif [[ "$DISTRO_ID" =~ ^(opensuse|suse) ]] || [[ "$DISTRO_LIKE" =~ suse ]]; then
        echo "  sudo zypper install cmake gcc-c++ extra-cmake-modules qt6-base-devel qt6-declarative-devel kf6-kwindowsystem-devel libplasma6-devel"
    else
        echo "  cmake, g++, extra-cmake-modules, Qt6 base+declarative dev, KF6 KWindowSystem dev, Plasma framework dev"
    fi
    echo ""
}

install_dependencies
print_dependency_hint

# 3. Build C++ Blur Plugin & Plasmoid
info "Configuring build with CMake..."
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

info "Building components..."
cmake --build build -j"$(nproc 2>/dev/null || echo 2)"

# 4. Install (paths determined by KDEInstallDirs6 via CMakeLists.txt)
info "Installing to system (requires sudo)..."
sudo cmake --install build

# 5. Also install icon into user directory as backup
USER_ICON_DIR="${HOME}/.local/share/icons/hicolor/256x256/apps"
if [ -f "assets/logo.png" ]; then
    mkdir -p "$USER_ICON_DIR"
    cp "assets/logo.png" "${USER_ICON_DIR}/com.github.mattanis.macosdock.png"
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f "${HOME}/.local/share/icons/hicolor" 2>/dev/null || true
    fi
else
    warn "assets/logo.png not found — skipping user icon installation."
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
