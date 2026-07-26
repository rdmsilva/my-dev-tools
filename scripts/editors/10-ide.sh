#!/usr/bin/env bash
#
# IDE Tools - Optional code editors/IDEs
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

OS=$(detect_os)
export OS

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

install_pycharm() {
    if command_exists pycharm-community; then
        log_ok "PyCharm Community already installed"
        return 0
    fi
    log_info "💻 Installing PyCharm Community Edition..."
    case "$OS" in
        arch)
            yay -S pycharm-community-edition 2>/dev/null || log_warn "PyCharm Community not available in AUR"
            ;;
        debian)
            sudo snap install pycharm-community --classic 2>/dev/null || log_warn "PyCharm Community not available via snap"
            ;;
        macos)
            brew install --cask pycharm-ce 2>/dev/null || log_warn "PyCharm Community install failed"
            ;;
    esac
}

install_intellij() {
    if command_exists idea; then
        log_ok "IntelliJ IDEA already installed"
        return 0
    fi
    log_info "💻 Installing IntelliJ IDEA Community Edition..."
    case "$OS" in
        arch)
            yay -S intellij-idea-community-edition 2>/dev/null || log_warn "IntelliJ IDEA not available in AUR"
            ;;
        debian)
            sudo snap install intellij-idea-community --classic 2>/dev/null || log_warn "IntelliJ IDEA not available via snap"
            ;;
        macos)
            brew install --cask intellij-idea-ce 2>/dev/null || log_warn "IntelliJ IDEA install failed"
            ;;
    esac
}

export -f install_vscode install_nvim install_pycharm install_intellij

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
gum_title "💻 IDE Tools"
while true; do
    set +e
    result=$(gum_multi_select "Select IDE tools to install (Space to mark, Enter to confirm, Ctrl+A for all):" \
        "VS Code" \
        "Neovim" \
        "PyCharm Community" \
        "IntelliJ IDEA Community")
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
            "VS Code") run_tool install_vscode "VS Code" ;;
            "Neovim") run_tool install_nvim "Neovim" ;;
            "PyCharm Community") run_tool install_pycharm "PyCharm Community" ;;
            "IntelliJ IDEA Community") run_tool install_intellij "IntelliJ IDEA Community" ;;
        esac
    done
done
