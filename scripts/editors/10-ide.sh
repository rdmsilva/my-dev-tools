#!/usr/bin/env bash
#
# IDE Tools - Optional code editors/IDEs
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)

install_vscode() {
    if command_exists code; then
        log_ok "VS Code already installed"
        return 0
    fi
    log_info "💻 Installing VS Code..."
    case "$OS" in
        arch)
            yay -S --needed visual-studio-code-bin 2>/dev/null || log_warn "VS Code not available in AUR"
            ;;
        debian)
            sudo apt install -y wget gpg
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
            rm -f packages.microsoft.gpg
            sudo apt update
            sudo apt install -y code
            ;;
        macos)
            brew install --cask visual-studio-code 2>/dev/null || log_warn "VS Code install failed"
            ;;
    esac
}

install_nvim() {
    if command_exists nvim; then
        log_ok "Neovim already installed"
        return 0
    fi
    log_info "💻 Installing Neovim..."
    case "$OS" in
        arch)
            sudo pacman -S --needed neovim 2>/dev/null || log_warn "Neovim not available in repos"
            ;;
        debian)
            sudo apt install -y neovim 2>/dev/null || log_warn "Neovim not available in repos"
            ;;
        macos)
            brew install neovim 2>/dev/null || log_warn "Neovim install failed"
            ;;
    esac
}

show_menu() {
    echo ""
    echo "========================================="
    echo "  IDE Tools Installer (Optional)"
    echo "========================================="
    echo ""
    echo "Select tools to install:"
    echo "  1) VS Code"
    echo "  2) Neovim"
    echo "  3) Install ALL"
    echo "  0) Back to main menu"
    echo ""
}

run_tool() {
    local tool="$1"
    local name="$2"
    echo ""
    log_info "Installing: $name"
    echo "-----------------------------------------"
    "$tool"
    local status=$?
    echo "-----------------------------------------"
    if [ $status -eq 0 ]; then
        log_ok "$name completed successfully"
    else
        log_error "$name failed with status $status"
    fi
    return $status
}

install_all() {
    run_tool install_vscode "VS Code"
    run_tool install_nvim "Neovim"
}

run_tool() {
    local tool="$1"
    local name="$2"
    echo ""
    log_info "Installing: $name"
    echo "-----------------------------------------"
    "$tool"
    local status=$?
    echo "-----------------------------------------"
    if [ $status -eq 0 ]; then
        log_ok "$name completed successfully"
    else
        log_error "$name failed with status $status"
    fi
    return $status
}

result=$(multi_select_menu "Select IDE tools to install:" \
    "VS Code" \
    "Neovim")

if [[ "$result" == "QUIT" ]]; then
    log_info "Exiting."
    exit 0
elif [[ -n "$result" ]]; then
    selections=($result)
    for sel in "${selections[@]}"; do
        case $sel in
            1) run_tool install_vscode "VS Code" ;;
            2) run_tool install_nvim "Neovim" ;;
        esac
    done
else
    log_info "No tools selected"
fi
