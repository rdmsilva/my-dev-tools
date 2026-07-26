#!/usr/bin/env bash
#
# Extra CLI tools - fzf, bat, eza, ripgrep, fd, etc.
#
# This file is meant to be run directly (shows its own submenu) or sourced
# by scripts/base/01-base.sh to reuse the install_* functions.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

OS=$(detect_os)
export OS

install_fzf() {
    if command_exists fzf; then
        log_ok "fzf already installed"
    else
        log_info "🔧 Installing fzf..."
        pkg_install fzf
    fi
    if [[ -d "$HOME/.fzf" ]]; then
        "$HOME/.fzf/install" --all --no-update-rc --no-bash --no-fish 2>/dev/null || true
    fi
}

install_bat() {
    if command_exists bat || command_exists batcat; then
        log_ok "bat already installed"
        return 0
    fi
    log_info "🔧 Installing bat..."
    pkg_install bat
}

install_eza() {
    if command_exists eza; then
        log_ok "eza already installed"
        return 0
    fi
    log_info "🔧 Installing eza..."
    pkg_install eza
}

install_ripgrep() {
    if command_exists rg; then
        log_ok "ripgrep already installed"
        return 0
    fi
    log_info "🔧 Installing ripgrep..."
    pkg_install ripgrep
}

install_fd() {
    if command_exists fd || command_exists fdfind; then
        log_ok "fd already installed"
        return 0
    fi
    log_info "🔧 Installing fd..."
    case "$OS" in
        debian) pkg_install fd-find ;;
        *) pkg_install fd ;;
    esac
}

install_htop() {
    if command_exists htop; then
        log_ok "htop already installed"
        return 0
    fi
    log_info "🔧 Installing htop..."
    pkg_install htop
}

install_btop() {
    if command_exists btop; then
        log_ok "btop already installed"
        return 0
    fi
    log_info "🔧 Installing btop..."
    pkg_install btop
}

install_ag() {
    if command_exists ag; then
        log_ok "ag (the_silver_searcher) already installed"
        return 0
    fi
    log_info "🔧 Installing the_silver_searcher (ag)..."
    case "$OS" in
        debian) pkg_install silversearcher-ag ;;
        *) pkg_install the_silver_searcher ;;
    esac
}

install_tree() {
    if command_exists tree; then
        log_ok "tree already installed"
        return 0
    fi
    log_info "🔧 Installing tree..."
    pkg_install tree
}

install_tldr() {
    if command_exists tldr; then
        log_ok "tldr already installed"
        return 0
    fi
    log_info "🔧 Installing tldr..."
    case "$OS" in
        debian) pip install tldr 2>/dev/null || pip3 install tldr 2>/dev/null || true ;;
        *) pkg_install tldr ;;
    esac
}

install_kitty() {
    if command_exists kitty; then
        log_ok "kitty already installed"
        return 0
    fi
    log_info "🔧 Installing kitty..."
    case "$OS" in
        macos) brew install --cask kitty 2>/dev/null || brew install kitty ;;
        *) pkg_install kitty ;;
    esac
}

install_lazygit() {
    if command_exists lazygit; then
        log_ok "lazygit already installed"
        return 0
    fi
    log_info "🔧 Installing lazygit..."
    case "$OS" in
        debian)
            local version
            version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -o '"tag_name": *"v[^"]*"' | grep -o '[^v]*$')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit /usr/local/bin
            rm -f /tmp/lazygit /tmp/lazygit.tar.gz
            ;;
        *) pkg_install lazygit ;;
    esac
}

EXTRA_TOOLS_MENU=(
    "fzf — Fuzzy finder"
    "bat — Better cat with syntax highlighting"
    "eza — Modern ls replacement"
    "ripgrep (rg) — Fast grep"
    "fd — Fast find"
    "htop — Interactive process viewer"
    "btop — System monitor"
    "ag (the_silver_searcher) — Fast code search"
    "tree — Directory tree viewer"
    "tldr — Simplified man pages"
    "kitty — GPU-accelerated terminal"
    "lazygit — Terminal Git UI"
)

install_extra_tool() {
    case "$1" in
        "fzf — Fuzzy finder") install_fzf ;;
        "bat — Better cat with syntax highlighting") install_bat ;;
        "eza — Modern ls replacement") install_eza ;;
        "ripgrep (rg) — Fast grep") install_ripgrep ;;
        "fd — Fast find") install_fd ;;
        "htop — Interactive process viewer") install_htop ;;
        "btop — System monitor") install_btop ;;
        "ag (the_silver_searcher) — Fast code search") install_ag ;;
        "tree — Directory tree viewer") install_tree ;;
        "tldr — Simplified man pages") install_tldr ;;
        "kitty — GPU-accelerated terminal") install_kitty ;;
        "lazygit — Terminal Git UI") install_lazygit ;;
    esac
}

export -f install_fzf install_bat install_eza install_ripgrep install_fd \
    install_htop install_btop install_ag install_tree install_tldr \
    install_kitty install_lazygit install_extra_tool

run_extra_tool() {
    local name="$1"
    gum spin --spinner dot --title "Installing: $name" --show-output -- \
        bash -c 'install_extra_tool "$1"' _ "$name"
    local status=$?
    if [ $status -ne 0 ]; then
        log_error "$name failed with status $status"
    fi
    return $status
}

# Only show the interactive menu when run directly; base/01-base.sh sources
# this file just to reuse the install_* functions above.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clear
    gum_title "🔧 Extra Tools"
    while true; do
        set +e
        result=$(gum_multi_select "Select extra tools to install (Space to mark, Enter to confirm, Ctrl+A for all):" "${EXTRA_TOOLS_MENU[@]}")
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
            run_extra_tool "$sel"
        done
    done
fi
