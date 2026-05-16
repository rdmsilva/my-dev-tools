#!/usr/bin/env bash
#
# Install Python via pyenv
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "🐍 Installing Python (pyenv) for $OS..."

# Install dependencies
case "$OS" in
    arch)
        packages_to_install=()
        for pkg in base-devel openssl zlib bzip2 libffi readline sqlite tk xz; do
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
        for pkg in build-essential libssl-dev zlib1g-dev libbz2-dev \
            libreadline-dev libsqlite3-dev libncursesw5-dev \
            libffi-dev liblzma-dev tk-dev; do
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
        for pkg in openssl readline sqlite3 xz zlib tcl-tk; do
            if ! brew list --formula "$pkg" &>/dev/null; then
                echo "  Installing $pkg..."
                brew install "$pkg"
            else
                echo "  $pkg already installed"
            fi
        done
        ;;
esac

# Install pyenv
if [[ ! -d "$HOME/.pyenv" ]]; then
    echo "  Installing pyenv..."
    curl -fsSL https://pyenv.run | bash
else
    echo "  pyenv already installed"
    cd "$HOME/.pyenv" && git pull
fi

# Add pyenv to shell config
PYENV_INIT='
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
'

CONFIG_FILE="$HOME/.zshrc"
if ! grep -q "pyenv" "$CONFIG_FILE" 2>/dev/null; then
    echo "  Adding pyenv to .zshrc..."
    echo "$PYENV_INIT" >> "$CONFIG_FILE"
else
    echo "  pyenv already configured in .zshrc"
fi

echo ""
echo "✅ Python (pyenv) setup complete."
echo "Install a Python version with: pyenv install <version>"
echo "Example: pyenv install 3.12.0 && pyenv global 3.12.0"
