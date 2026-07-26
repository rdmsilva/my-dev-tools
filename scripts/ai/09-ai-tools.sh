#!/usr/bin/env bash
#
# AI Tools - Optional AI-powered coding assistants
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

OS=$(detect_os)
export OS

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

export -f install_copilot install_opencode install_cursor install_hermes

run_tool() {
    local tool="$1"
    local name="$2"
    gum spin --spinner dot --title "Installing: $name" --show-output -- bash -c "$tool"
    local status=$?
    if [ $status -ne 0 ]; then
        log_error "$name failed with status $status"
    fi
    return $status
}

clear
gum_title "🤖 AI Tools"
while true; do
    set +e
    result=$(gum_multi_select "Select AI tools to install (Space to mark, Enter to confirm, Ctrl+A for all):" \
        "GitHub Copilot CLI" \
        "opencode" \
        "Cursor" \
        "Hermes Agent")
    gum_status=$?
    set -e

    if [[ $gum_status -ne 0 ]]; then
        clear
        exit 130
    fi

    if [[ -z "$result" ]]; then
        log_warn "No tools selected. Press Space to mark an item, then Enter to confirm (or Esc to quit)."
        continue
    fi

    mapfile -t selections <<< "$result"
    for sel in "${selections[@]}"; do
        case "$sel" in
            "GitHub Copilot CLI") run_tool install_copilot "GitHub Copilot CLI" ;;
            "opencode") run_tool install_opencode "opencode" ;;
            "Cursor") run_tool install_cursor "Cursor" ;;
            "Hermes Agent") run_tool install_hermes "Hermes Agent" ;;
        esac
    done
done
