#!/usr/bin/env bash
#
# Install base system packages
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "📦 Installing base packages for $OS..."

case "$OS" in
    arch)
        echo "  Installing base-devel, git, curl, wget, unzip, jq, github-cli..."
        sudo pacman -S --noconfirm --needed \
            base-devel git curl wget unzip jq github-cli \
            openssl openssh ca-certificates \
            file findutils grep sed gawk
        ;;

    debian)
        echo "  Updating package lists..."
        sudo apt update

        packages_to_install=()
        for pkg in build-essential git curl wget unzip jq gh \
            software-properties-common apt-transport-https \
            ca-certificates gnupg lsb-release \
            openssl openssh-client; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                packages_to_install+=("$pkg")
            else
                echo "  $pkg already installed"
            fi
        done

        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            echo "  Installing: ${packages_to_install[*]}"
            sudo apt install -y "${packages_to_install[@]}"
        else
            echo "  All base packages already installed"
        fi
        ;;

    macos)
        echo "  Checking Homebrew..."
        if ! command_exists brew; then
            echo "  Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        echo "  Installing core packages..."
        for pkg in git curl wget unzip jq gh openssl coreutils; do
            if ! brew list --formula "$pkg" &>/dev/null; then
                echo "  Installing $pkg..."
                brew install "$pkg"
            else
                echo "  $pkg already installed"
            fi
        done
        ;;

    *)
        echo "ERROR: Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "✅ Base packages installed."
