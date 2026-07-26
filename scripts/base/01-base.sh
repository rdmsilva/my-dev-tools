#!/usr/bin/env bash
#
# Base system packages + extra CLI tools
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
source "$SCRIPT_DIR/../terminal/08-extras.sh"

OS=$(detect_os)
export OS

install_base() {
    echo "📦 Installing base packages for $OS..."
    case "$OS" in
        arch)
            echo "  Installing base-devel, git, curl, wget, unzip, jq, github-cli..."
            sudo pacman -S --noconfirm --needed \
                base-devel git curl wget unzip jq github-cli \
                openssl openssh ca-certificates \
                file findutils grep sed gawk
            ;;

        debian)
            echo "  Updating package lists..."
            sudo apt update

            packages_to_install=()
            for pkg in build-essential git curl wget unzip jq gh \
                software-properties-common apt-transport-https \
                ca-certificates gnupg lsb-release \
                openssl openssh-client; do
                if ! dpkg -s "$pkg" &>/dev/null; then
                    packages_to_install+=("$pkg")
                else
                    echo "  $pkg already installed"
                fi
            done

            if [[ ${#packages_to_install[@]} -gt 0 ]]; then
                echo "  Installing: ${packages_to_install[*]}"
                sudo apt install -y "${packages_to_install[@]}"
            else
                echo "  All base packages already installed"
            fi
            ;;

        macos)
            echo "  Checking Homebrew..."
            if ! command_exists brew; then
                echo "  Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi

            echo "  Installing core packages..."
            for pkg in git curl wget unzip jq gh openssl coreutils; do
                if ! brew list --formula "$pkg" &>/dev/null; then
                    echo "  Installing $pkg..."
                    brew install "$pkg"
                else
                    echo "  $pkg already installed"
                fi
            done
            ;;

        *)
            echo "ERROR: Unsupported OS: $OS"
            return 1
            ;;
    esac

    echo "✅ Base packages installed."
}

BASE_LABEL="📦 Base system packages — Core dev packages (git, curl, wget, jq, build tools)"

export -f install_base

run_item() {
    local name="$1"
    if [[ "$name" == "$BASE_LABEL" ]]; then
        gum spin --spinner dot --title "Installing: $name" --show-output -- bash -c 'install_base'
    else
        gum spin --spinner dot --title "Installing: $name" --show-output -- \
            bash -c 'install_extra_tool "$1"' _ "$name"
    fi
    local status=$?
    if [ $status -ne 0 ]; then
        log_error "$name failed with status $status"
    fi
    return $status
}

clear
gum_title "🧰 Base & Extra Tools"
while true; do
    set +e
    result=$(gum_multi_select "Select tools to install (Space to mark, Enter to confirm, Ctrl+A for all):" "$BASE_LABEL" "${EXTRA_TOOLS_MENU[@]}")
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
        run_item "$sel"
    done
done
