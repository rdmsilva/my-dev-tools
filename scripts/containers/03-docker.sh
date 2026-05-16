#!/usr/bin/env bash
#
# Install Docker + Docker Compose
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "🐳 Installing Docker for $OS..."

case "$OS" in
    arch)
        if command_exists docker; then
            echo "  Docker already installed"
        else
            echo "  Installing docker and docker-compose..."
            sudo pacman -S --noconfirm --needed docker docker-compose
        fi

        echo "  Enabling docker service..."
        sudo systemctl enable docker
        sudo systemctl start docker

        if [[ -n "${SUDO_USER:-}" ]]; then
            echo "  Adding user $SUDO_USER to docker group..."
            sudo usermod -aG docker "$SUDO_USER"
        fi
        ;;

    debian)
        if command_exists docker; then
            echo "  Docker already installed"
        else
            echo "  Installing Docker official repository..."

            # Remove old versions
            sudo apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true

            # Install prerequisites
            sudo apt install -y ca-certificates curl gnupg

            # Add Docker GPG key
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
                -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            # Add repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
                https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi

        echo "  Enabling docker service..."
        sudo systemctl enable docker
        sudo systemctl start docker

        if [[ -n "${SUDO_USER:-}" ]]; then
            echo "  Adding user $SUDO_USER to docker group..."
            sudo usermod -aG docker "$SUDO_USER"
        fi
        ;;

    macos)
        echo "  Docker Desktop for macOS must be installed manually."
        echo "  Download from: https://www.docker.com/products/docker-desktop/"
        echo ""
        echo "  Alternatively, install colima (lightweight alternative):"
        echo "    brew install colima docker"
        echo "    colima start"
        ;;
esac

echo ""
echo "✅ Docker setup complete."
echo "Note: You may need to log out and back in for group changes to take effect."
