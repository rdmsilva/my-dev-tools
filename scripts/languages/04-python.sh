#!/usr/bin/env bash
#
# Python tooling - choose pyenv, uv, or both
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

OS=$(detect_os)
export OS

install_pyenv() {
    log_info "🐍 Installing pyenv build dependencies..."
    case "$OS" in
        arch)
            packages_to_install=()
            for pkg in base-devel openssl zlib bzip2 libffi readline sqlite tk xz; do
                if ! pacman -Q "$pkg" &>/dev/null; then
                    packages_to_install+=("$pkg")
                else
                    echo "  $pkg already installed"
                fi
            done
            if [[ ${#packages_to_install[@]} -gt 0 ]]; then
                sudo pacman -S --noconfirm --needed "${packages_to_install[@]}"
            fi
            ;;
        debian)
            packages_to_install=()
            for pkg in build-essential libssl-dev zlib1g-dev libbz2-dev \
                libreadline-dev libsqlite3-dev libncursesw5-dev \
                libffi-dev liblzma-dev tk-dev; do
                if ! dpkg -s "$pkg" &>/dev/null; then
                    packages_to_install+=("$pkg")
                else
                    echo "  $pkg already installed"
                fi
            done
            if [[ ${#packages_to_install[@]} -gt 0 ]]; then
                sudo apt install -y "${packages_to_install[@]}"
            fi
            ;;
        macos)
            for pkg in openssl readline sqlite3 xz zlib tcl-tk; do
                if ! brew list --formula "$pkg" &>/dev/null; then
                    echo "  Installing $pkg..."
                    brew install "$pkg"
                else
                    echo "  $pkg already installed"
                fi
            done
            ;;
    esac

    if [[ ! -d "$HOME/.pyenv" ]]; then
        echo "  Installing pyenv..."
        curl -fsSL https://pyenv.run | bash
    else
        echo "  pyenv already installed"
        cd "$HOME/.pyenv" && git pull
    fi

    PYENV_INIT='
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
'
    CONFIG_FILE="$HOME/.zshrc"
    if ! grep -q "pyenv" "$CONFIG_FILE" 2>/dev/null; then
        echo "  Adding pyenv to .zshrc..."
        echo "$PYENV_INIT" >> "$CONFIG_FILE"
    else
        echo "  pyenv already configured in .zshrc"
    fi

    echo ""
    echo "Install a Python version with: pyenv install <version>"
    echo "Example: pyenv install 3.12.0 && pyenv global 3.12.0"
}

install_uv() {
    if command_exists uv; then
        log_ok "uv already installed"
        return 0
    fi

    log_info "🐍 Installing uv..."
    case "$OS" in
        arch)
            sudo pacman -S --noconfirm --needed uv
            ;;
        debian)
            curl -LsSf https://astral.sh/uv/install.sh | sh
            ;;
        macos)
            brew install uv
            ;;
    esac

    echo ""
    echo "Create a project with: uv init myproject"
    echo "Install a Python version with: uv python install 3.12"
}

export -f install_pyenv install_uv

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
gum_title "🐍 Python Tooling"
while true; do
    set +e
    result=$(gum_multi_select "Select Python tooling to install (Space to mark, Enter to confirm, Ctrl+A for all):" \
        "pyenv" \
        "uv")
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
            "pyenv") run_tool install_pyenv "pyenv" ;;
            "uv") run_tool install_uv "uv" ;;
        esac
    done
done
