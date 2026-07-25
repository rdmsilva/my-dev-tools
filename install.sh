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

run_script_with_spinner() {
    local script="$1"
    local name="$2"

    if command_exists gum; then
        gum spin --spinner dot --title "Installing: $name" --show-output -- bash "$SCRIPT_DIR/scripts/$script"
        local status=$?
        if [ $status -eq 0 ]; then
            log_ok "$name completed successfully"
        else
            log_error "$name failed with status $status"
        fi
        return $status
    else
        run_script "$script" "$name"
    fi
}

install_selected() {
    local selections=("$@")
    for sel in "${selections[@]}"; do
        case $sel in
            "📦 Base system packages") run_script_with_spinner "base/01-base.sh" "Base system packages" ;;
            "🐚 Zsh + Oh My Zsh") run_script_with_spinner "shell/02-zsh.sh" "Zsh + Oh My Zsh" ;;
            "🐳 Docker") run_script_with_spinner "containers/03-docker.sh" "Docker" ;;
            "🐍 Python (pyenv)") run_script_with_spinner "languages/04-python.sh" "Python (pyenv)" ;;
            "🟢 Node.js (nvm)") run_script_with_spinner "languages/05-node.sh" "Node.js (nvm)" ;;
            "☕ Java (SDKMAN!)") run_script_with_spinner "languages/06-java.sh" "Java (SDKMAN!)" ;;
            "📝 Vim + plugins") run_script_with_spinner "editors/07-vim.sh" "Vim + plugins" ;;
            "🔧 Extra tools (fzf, bat, eza, etc.)") run_script_with_spinner "terminal/08-extras.sh" "Extra tools" ;;
            "🤖 AI tools") run_script_with_spinner "ai/09-ai-tools.sh" "AI tools" ;;
        esac
    done
}

# Main
echo ""
echo "========================================="
echo "  Development Tools"
echo "========================================="
echo ""
echo "OS: $OS"
echo ""

# Try to use gum for enhanced UI
ensure_gum

if command_exists gum; then
    # Use gum confirm to verify user wants to proceed
    if gum confirm "Run development environment setup?"; then
        while true; do
            set +e
            result=$(gum choose --no-limit --header "Select components to install (Space to select, Enter to confirm):" --cursor ">" --selected.foreground="212" \
                "📦 Base system packages" \
                "🐚 Zsh + Oh My Zsh" \
                "🐳 Docker" \
                "🐍 Python (pyenv)" \
                "🟢 Node.js (nvm)" \
                "☕ Java (SDKMAN!)" \
                "📝 Vim + plugins" \
                "🔧 Extra tools (fzf, bat, eza, etc.)" \
                "🤖 AI tools")
            gum_status=$?
            set -e

            if [[ $gum_status -ne 0 ]]; then
                # User pressed Esc/Ctrl+C
                result="QUIT"
                break
            fi

            if [[ -z "$result" ]]; then
                log_warn "No components selected. Press Space to mark an item, then Enter to confirm (or Esc to quit)."
                continue
            fi

            break
        done
    else
        result="QUIT"
    fi
else
    log_warn "gum not available, using basic menu"
    result=$(multi_select_menu "Select components to install:" \
        "📦 Base system packages" \
        "🐚 Zsh + Oh My Zsh" \
        "🐳 Docker" \
        "🐍 Python (pyenv)" \
        "🟢 Node.js (nvm)" \
        "☕ Java (SDKMAN!)" \
        "📝 Vim + plugins" \
        "🔧 Extra tools (fzf, bat, eza, etc.)" \
        "🤖 AI tools")
fi

if [[ "$result" == "QUIT" ]]; then
    log_info "Exiting. Bye!"
    exit 0
elif [[ -n "$result" ]]; then
    # gum returns newline-separated, old menu returns space-separated
    if command_exists gum; then
        mapfile -t selections <<< "$result"
    else
        selections=($result)
    fi

    # Show confirmation
    echo ""
    log_info "Selected components:"
    for sel in "${selections[@]}"; do
        echo "  → $sel"
    done
    echo ""

    if confirm "Proceed with installation?"; then
        install_selected "${selections[@]}"
    else
        log_info "Installation cancelled."
    fi
else
    log_info "No components selected. (gum installed: $(command_exists gum && echo yes || echo no))"
fi
