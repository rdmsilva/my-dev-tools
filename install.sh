#!/usr/bin/env bash
#
# My Shell Config - Development Environment Setup
# Supports: Arch Linux, Debian/Ubuntu, macOS
#

set -euo pipefail

clear

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/utils.sh"

# Detect OS
OS=$(detect_os)

run_script() {
    local script="$1"
    local name="$2"
    # No clear/header here: the submenu script itself clears the screen and
    # shows its own title as soon as it starts (see gum_title calls below).
    set +e
    bash "$SCRIPT_DIR/scripts/$script"
    local status=$?
    set -e
    if [ $status -eq 0 ]; then
        log_ok "$name completed successfully"
    elif [ $status -eq 130 ]; then
        : # user cancelled the submenu (Esc/Ctrl+C); it already logged that
    else
        log_error "$name failed with status $status"
    fi
    return 0
}

run_script_with_spinner() {
    local script="$1"
    local name="$2"

    set +e
    gum spin --spinner dot --title "Installing: $name" --show-output -- bash "$SCRIPT_DIR/scripts/$script"
    local status=$?
    set -e
    if [ $status -eq 0 ]; then
        log_ok "$name completed successfully"
    else
        log_error "$name failed with status $status"
    fi
    return 0
}

# Items that open their own multi-select submenu (run without a spinner so
# the interactive prompt inside is usable); everything else installs directly.
run_component() {
    local choice="$1"
    case "$choice" in
        "🧰 Base & Extra tools") run_script "base/01-base.sh" "Base & Extra tools" ;;
        "🐚 Zsh + Oh My Zsh") run_script_with_spinner "shell/02-zsh.sh" "Zsh + Oh My Zsh" ;;
        "🐳 Docker") run_script_with_spinner "containers/03-docker.sh" "Docker" ;;
        "🐍 Python (pyenv/uv)") run_script "languages/04-python.sh" "Python (pyenv/uv)" ;;
        "🟢 Node.js (nvm)") run_script_with_spinner "languages/05-node.sh" "Node.js (nvm)" ;;
        "☕ Java (SDKMAN!)") run_script_with_spinner "languages/06-java.sh" "Java (SDKMAN!)" ;;
        "📝 Vim + plugins") run_script_with_spinner "editors/07-vim.sh" "Vim + plugins" ;;
        "🤖 AI tools") run_script "ai/09-ai-tools.sh" "AI tools" ;;
        "💻 IDE tools") run_script "editors/10-ide.sh" "IDE tools" ;;
    esac
}

MENU_ITEMS=(
    "🧰 Base & Extra tools"
    "🐚 Zsh + Oh My Zsh"
    "🐳 Docker"
    "🐍 Python (pyenv/uv)"
    "🟢 Node.js (nvm)"
    "☕ Java (SDKMAN!)"
    "📝 Vim + plugins"
    "🤖 AI tools"
    "💻 IDE tools"
    "🚪 Exit"
)

# gum is required for the interactive menu (and for logging), so check
# before relying on log_error, which itself shells out to `gum log`.
ensure_gum
if ! command_exists gum; then
    echo "ERROR: gum is required to run this installer and could not be installed on this OS ($OS)." >&2
    exit 1
fi

# Pre-authenticate sudo here, in the plain foreground, on OSes where component
# scripts actually use it (arch/debian: pacman/apt, systemctl, usermod, etc.).
# macOS components are all plain `brew` calls and never touch sudo, so skip
# this there instead of prompting for a password nothing will use.
# Component scripts call `sudo` while wrapped in `gum spin`, which takes over
# the terminal to draw the animation — if sudo needed a password at that
# point, the prompt would be invisible/unusable and the spinner would look
# frozen. Keep the sudo timestamp refreshed in the background for the rest
# of the session.
if [[ "$OS" != "macos" ]]; then
    if ! sudo -n true 2>/dev/null; then
        log_info "Alguns componentes usam sudo — informe sua senha para continuar:"
    fi
    sudo -v
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
fi

# Main
MENU_HEIGHT=$(( ${#MENU_ITEMS[@]} + 2 ))
while true; do
    gum_title "🚀 Welcome DevTools" "Development Environment Setup" "OS: $OS"
    echo ""
    set +e
    choice=$(gum choose --header "Select a component to install (Enter to select, Esc to quit):" --cursor ">" --height "$MENU_HEIGHT" --padding "1 2" "${MENU_ITEMS[@]}")
    gum_status=$?
    set -e

    if [[ $gum_status -ne 0 ]]; then
        # Esc/Ctrl+C: gum leaves a "nothing selected" line behind, erase it.
        printf '\033[1A\033[2K'
    fi

    if [[ $gum_status -ne 0 || -z "$choice" || "$choice" == "🚪 Exit" ]]; then
        log_info "Bye!"
        break
    fi

    run_component "$choice"
done
