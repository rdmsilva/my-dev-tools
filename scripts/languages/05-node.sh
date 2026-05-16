#!/usr/bin/env bash
#
# Install Node.js via nvm
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)
echo "🟢 Installing Node.js (nvm) for $OS..."

# Install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "  Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
    echo "  nvm already installed"
    cd "$HOME/.nvm" && git pull
fi

# Add nvm to shell config
NVM_INIT='
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
'

CONFIG_FILE="$HOME/.zshrc"
if ! grep -q "nvm" "$CONFIG_FILE" 2>/dev/null; then
    echo "  Adding nvm to .zshrc..."
    echo "$NVM_INIT" >> "$CONFIG_FILE"
else
    echo "  nvm already configured in .zshrc"
fi

# Source nvm for this session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo ""
echo "✅ Node.js (nvm) setup complete."
echo "Install a Node version with: nvm install <version>"
echo "Example: nvm install --lts && nvm use --lts"
