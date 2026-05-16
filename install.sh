#!/usr/bin/env bash
#
# My Shell Config - Development Environment Setup
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/utils.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
E_INFO='ℹ️'
E_OK='✅'
E_WARN='⚠️'
E_ERROR='❌'
E_PKG='📦'
E_CODE='💻'
E_SHELL='🐚'
E_DOCKER='🐳'
E_PYTHON='🐍'
E_NODE='🟢'
E_JAVA='☕'
E_VIM='📝'
E_AI='🤖'
E_TOOLS='🔧'
E_TERM='🖥️'

log_info()  { echo -e "${BLUE}${E_INFO}${NC} $1"; }
log_ok()    { echo -e "${GREEN}${E_OK}${NC} $1"; }
log_warn()  { echo -e "${YELLOW}${E_WARN}${NC} $1"; }
log_error() { echo -e "${RED}${E_ERROR}${NC} $1"; }

# Detect OS
OS=$(detect_os)
log_info "Detected OS: $OS"

run_script() {
    local script="$1"
    local name="$2"
    echo ""
    log_info "Installing: $name"
    echo "-----------------------------------------"
    bash "$SCRIPT_DIR/scripts/$script"
    local status=$?
    echo "-----------------------------------------"
    if [ $status -eq 0 ]; then
        log_ok "$name completed successfully"
    else
        log_error "$name failed with status $status"
    fi
    return $status
}

install_selected() {
    local selections=("$@")
    for sel in "${selections[@]}"; do
        case $sel in
            1) run_script "base/01-base.sh" "📦 Base system packages" ;;
            2) run_script "shell/02-zsh.sh" "🐚 Zsh + Oh My Zsh" ;;
            3) run_script "containers/03-docker.sh" "🐳 Docker" ;;
            4) run_script "languages/04-python.sh" "🐍 Python (pyenv)" ;;
            5) run_script "languages/05-node.sh" "🟢 Node.js (nvm)" ;;
            6) run_script "languages/06-java.sh" "☕ Java (SDKMAN!)" ;;
            7) run_script "editors/07-vim.sh" "📝 Vim + plugins" ;;
            8) run_script "terminal/08-extras.sh" "🔧 Extra tools" ;;
        esac
    done
}

# Main
echo ""
echo "========================================="
echo "  Development Environment Setup"
echo "========================================="
echo ""
echo "OS: $OS"
echo ""

result=$(multi_select_menu "Select components to install:" \
    "📦 Base system packages" \
    "🐚 Zsh + Oh My Zsh" \
    "🐳 Docker" \
    "🐍 Python (pyenv)" \
    "🟢 Node.js (nvm)" \
    "☕ Java (SDKMAN!)" \
    "📝 Vim + plugins" \
    "🔧 Extra tools (fzf, bat, eza, etc.)")

if [[ "$result" == "QUIT" ]]; then
    log_info "Exiting. Bye!"
    exit 0
elif [[ -n "$result" ]]; then
    selections=($result)
    install_selected "${selections[@]}"
else
    log_info "No components selected. Use [a] to select all."
fi
