#!/usr/bin/env bash
#
# Install extra development tools
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "🔧 Installing extra tools for $OS..."

case "$OS" in
    arch)
        packages_to_install=()
        for pkg in fzf bat eza ripgrep fd htop btop lazygit the_silver_searcher tree tldr kitty; do
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
        sudo apt update
        packages_to_install=()
        for pkg in fzf bat eza ripgrep fd-find htop btop tree silversearcher-ag kitty; do
            if ! dpkg -s "$pkg" &>/dev/null; then
                packages_to_install+=("$pkg")
            else
                echo "  $pkg already installed"
            fi
        done
        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            sudo apt install -y "${packages_to_install[@]}"
        fi

        # lazygit from GitHub releases
        if ! command_exists lazygit; then
            echo "  Installing lazygit..."
            LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -o '"tag_name": *"v[^"]*"' | grep -o '[^v]*$')
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm -rf lazygit lazygit.tar.gz
        fi

        # tldr via pip
        if ! command_exists tldr; then
            pip install tldr 2>/dev/null || pip3 install tldr 2>/dev/null || true
        fi
        ;;

    macos)
        for pkg in fzf bat eza ripgrep fd btop lazygit the_silver_searcher tree tldr htop kitty; do
            if ! brew list --formula "$pkg" &>/dev/null && ! brew list --cask "$pkg" &>/dev/null; then
                echo "  Installing $pkg..."
                brew install --cask "$pkg" 2>/dev/null || brew install "$pkg"
            else
                echo "  $pkg already installed"
            fi
        done
        ;;
esac

# Setup fzf key bindings if not already done
if [[ -d "$HOME/.fzf" ]]; then
    echo "  Setting up fzf key bindings..."
    "$HOME/.fzf/install" --all --no-update-rc --no-bash --no-fish 2>/dev/null || true
fi

echo ""
echo "✅ Extra tools installed:"
echo "  fzf       - Fuzzy finder"
echo "  bat       - Better cat with syntax highlighting"
echo "  eza       - Modern ls replacement"
echo "  ripgrep   - Fast grep (rg)"
echo "  fd        - Fast find (fd)"
echo "  btop      - System monitor"
echo "  lazygit   - Terminal Git UI"
echo "  tree      - Directory tree viewer"
echo "  tldr      - Simplified man pages"
echo "  kitty     - GPU-accelerated terminal emulator"
