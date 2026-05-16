#!/usr/bin/env bash
#
# Install Java via SDKMAN!
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "☕ Installing Java (SDKMAN!) for $OS..."

# Install prerequisites
case "$OS" in
    arch)
        packages_to_install=()
        for pkg in zip unzip curl; do
            if ! pacman -Q "$pkg" &>/dev/null; then
                packages_to_install+=("$pkg")
            else
                echo "  $pkg already installed"
            fi
        done
        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            sudo pacman -S --noconfirm --needed "${packages_to_install[@]}"
        fi
        ;;
    debian)
        packages_to_install=()
        for pkg in zip unzip curl; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                packages_to_install+=("$pkg")
            else
                echo "  $pkg already installed"
            fi
        done
        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            sudo apt install -y "${packages_to_install[@]}"
        fi
        ;;
    macos)
        for pkg in zip unzip curl; do
            if ! brew list --formula "$pkg" &>/dev/null; then
                echo "  Installing $pkg..."
                brew install "$pkg"
            else
                echo "  $pkg already installed"
            fi
        done
        ;;
esac

# Install SDKMAN!
if [[ ! -d "$HOME/.sdkman" ]]; then
    echo "  Installing SDKMAN!..."
    curl -s "https://get.sdkman.io" | bash
else
    echo "  SDKMAN! already installed"
fi

# Source SDKMAN! for this session
if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Add SDKMAN! to shell config
SDKMAN_INIT='
# SDKMAN!
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
'

CONFIG_FILE="$HOME/.zshrc"
if ! grep -q "sdkman" "$CONFIG_FILE" 2>/dev/null; then
    echo "  Adding SDKMAN! to .zshrc..."
    echo "$SDKMAN_INIT" >> "$CONFIG_FILE"
else
    echo "  SDKMAN! already configured in .zshrc"
fi

echo ""
echo "✅ Java (SDKMAN!) setup complete."
echo "Install a JDK with: sdk install java <version>"
echo "Example: sdk install java 21.0.0-tem"
echo ""
echo "SDKMAN! also manages: gradle, maven, kotlin, scala, groovy, and more."
