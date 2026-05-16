#!/usr/bin/env bash
#
# AI Tools - Optional AI-powered coding assistants
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

OS=$(detect_os)

install_copilot() {
    if command_exists github-copilot-cli; then
        log_ok "GitHub Copilot CLI already installed"
        return 0
    fi
    log_info "🤖 Installing GitHub Copilot CLI..."
    case "$OS" in
        arch)
            yay -S --needed github-copilot-cli 2>/dev/null || log_warn "Copilot CLI not available in AUR"
            ;;
        debian)
            log_warn "Copilot CLI: Install manually from https://github.com/github/copilot-cli"
            ;;
        macos)
            brew install github/copilot-cli/copilot-cli 2>/dev/null || log_warn "Copilot CLI install failed"
            ;;
    esac
}

install_opencode() {
    if command_exists opencode; then
        log_ok "opencode already installed"
        return 0
    fi
    log_info "🤖 Installing opencode..."
    case "$OS" in
        arch)
            yay -S --needed opencode 2>/dev/null || log_warn "opencode not available in AUR"
            ;;
        debian)
            log_warn "opencode: Install manually from https://opencode.ai"
            ;;
        macos)
            brew install opencode 2>/dev/null || log_warn "opencode install failed"
            ;;
    esac
}

install_cursor() {
    if command_exists cursor; then
        log_ok "Cursor already installed"
        return 0
    fi
    log_info "🤖 Installing Cursor..."
    case "$OS" in
        arch)
            yay -S --needed cursor-bin 2>/dev/null || log_warn "Cursor not available in AUR"
            ;;
        debian)
            log_warn "Cursor: Install manually from https://cursor.sh"
            ;;
        macos)
            brew install --cask cursor 2>/dev/null || log_warn "Cursor install failed"
            ;;
    esac
}

install_hermes() {
    if command_exists hermes; then
        log_ok "Hermes already installed"
        return 0
    fi
    log_info "🤖 Installing Hermes Agent..."
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
}

show_menu() {
    echo ""
    echo "========================================="
    echo "  AI Tools Installer (Optional)"
    echo "========================================="
    echo ""
    echo "Select tools to install:"
    echo "  1) GitHub Copilot CLI"
    echo "  2) opencode"
    echo "  3) Cursor"
    echo "  4) Hermes"
    echo "  5) Install ALL"
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
    run_tool install_copilot "GitHub Copilot CLI"
    run_tool install_opencode "opencode"
    run_tool install_cursor "Cursor"
    run_tool install_hermes "Hermes Agent"
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

result=$(multi_select_menu "Select AI tools to install:" \
    "GitHub Copilot CLI" \
    "opencode" \
    "Cursor" \
    "Hermes Agent")


if [[ "$result" == "QUIT" ]]; then
    log_info "Exiting."
    exit 0
elif [[ -n "$result" ]]; then
    selections=($result)
    for sel in "${selections[@]}"; do
        case $sel in
            1) run_tool install_copilot "GitHub Copilot CLI" ;;
            2) run_tool install_opencode "opencode" ;;
            3) run_tool install_cursor "Cursor" ;;
            4) run_tool install_hermes "Hermes Agent" ;;
        esac
    done
else
    log_info "No tools selected"
fi
