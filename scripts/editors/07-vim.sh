#!/usr/bin/env bash
#
# Install Vim + plugins (vim-plug)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "📝 Installing Vim for $OS..."

# Install vim
if ! command_exists vim; then
    case "$OS" in
        arch)    sudo pacman -S --noconfirm vim ;;
        debian)  sudo apt install -y vim ;;
        macos)   brew install vim ;;
    esac
else
    echo "  vim already installed"
fi

# Install vim-plug
PLUG_FILE="$HOME/.vim/autoload/plug.vim"
if [[ ! -f "$PLUG_FILE" ]]; then
    echo "  Installing vim-plug..."
    curl -fLo "$PLUG_FILE" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "  vim-plug already installed"
fi

# Link config files
echo ""
echo "Linking configuration files..."
SCRIPT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
link_config "$SCRIPT_ROOT/configs/.vimrc" ".vimrc"

# Install plugins
echo ""
echo "Installing Vim plugins..."
vim +PlugInstall +qall 2>/dev/null || true

echo ""
echo "✅ Vim setup complete."
