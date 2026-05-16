#!/usr/bin/env bash
#
# Install Zsh + Oh My Zsh + plugins
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "🐚 Installing Zsh for $OS..."

# Install zsh
if ! command_exists zsh; then
    case "$OS" in
        arch)    sudo pacman -S --noconfirm zsh ;;
        debian)  sudo apt install -y zsh ;;
        macos)   brew install zsh ;;
    esac
else
    echo "  zsh already installed"
fi

# Set as default shell (non-interactive)
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "  Setting zsh as default shell..."
    chsh -s "$(command -v zsh)" 2>/dev/null || true
fi

# Install Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "  Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "  Oh My Zsh already installed"
fi

# Install plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "  Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "  zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "  Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "  zsh-syntax-highlighting already installed"
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    echo "  Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions \
        "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo "  zsh-completions already installed"
fi

# Powerlevel10k theme
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    echo "  Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    echo "  Powerlevel10k already installed"
fi

# Link config files
echo ""
echo "Linking configuration files..."
SCRIPT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
link_config "$SCRIPT_ROOT/configs/.zshrc" ".zshrc"
link_config "$SCRIPT_ROOT/configs/.zsh_aliases" ".zsh_aliases"

echo ""
echo "✅ Zsh setup complete. Restart your terminal or run: exec zsh"
