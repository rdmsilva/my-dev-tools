#!/usr/bin/env bash
#
# Utility functions for multi-OS support
#

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

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}${E_INFO}${NC} $1"; }
log_ok()    { echo -e "${GREEN}${E_OK}${NC} $1"; }
log_warn()  { echo -e "${YELLOW}${E_WARN}${NC} $1"; }
log_error() { echo -e "${RED}${E_ERROR}${NC} $1"; }

# Detect operating system
# Returns: arch | debian | macos
detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
        return
    fi

    if [[ -f /etc/os-release ]]; then
        local id=$(. /etc/os-release && echo "$ID")
        local id_like=$(. /etc/os-release && echo "$ID_LIKE")

        case "$id" in
            arch|manjaro|endeavouros)
                echo "arch"
                return
                ;;
            debian|ubuntu|linuxmint|pop)
                echo "debian"
                return
                ;;
        esac

        # Check ID_LIKE for derivatives
        if [[ "$id_like" == *"debian"* || "$id_like" == *"ubuntu"* ]]; then
            echo "debian"
            return
        elif [[ "$id_like" == *"arch"* ]]; then
            echo "arch"
            return
        fi
    fi

    echo "unknown"
}

# Install packages based on OS
# Usage: pkg_install <package1> [package2] ...
pkg_install() {
    local os
    os=$(detect_os)

    case "$os" in
        arch)
            sudo pacman -S --noconfirm --needed "$@"
            ;;
        debian)
            sudo apt update
            sudo apt install -y "$@"
            ;;
        macos)
            brew install "$@"
            ;;
        *)
            echo "ERROR: Unsupported OS"
            return 1
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Prompt user for confirmation
confirm() {
    local msg="$1"
    echo ""
    read -p "$msg (y/N): " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Link config file to home directory
link_config() {
    local src="$1"
    local dest="$HOME/$2"
    local filename
    filename=$(basename "$dest")

    if [[ -L "$dest" ]]; then
        echo "  ⏭️  $filename already linked"
        return
    fi

    if [[ -f "$dest" ]]; then
        if confirm "$filename exists. Backup and replace?"; then
            mv "$dest" "${dest}.bak.$(date +%Y%m%d%H%M%S)"
        else
            echo "  ⏭️  $filename"
            return
        fi
    fi

    ln -sf "$src" "$dest"
    echo "  🔗 $filename"
}

# Install AUR helper (yay) for Arch
install_yay() {
    if command_exists yay; then
        echo "  ✅ yay already installed"
        return
    fi

    echo "  📦 Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /tmp
    rm -rf yay
    echo "  ✅ yay installed"
}

# Install AUR package
aur_install() {
    local os
    os=$(detect_os)

    case "$os" in
        arch)
            install_yay
            yay -S --noconfirm --needed "$@"
            ;;
        debian)
            echo "  AUR packages not available on Debian"
            ;;
        macos)
            echo "  AUR packages not available on macOS"
            ;;
    esac
}

# Multi-select menu with checkboxes
# Usage: multi_select_menu "Title" "Item1" "Item2" "Item3"
# Returns: space-separated selected indices (1-based)
multi_select_menu() {
    local title="$1"
    shift
    local items=("$@")
    local count=${#items[@]}
    local selected=()
    local choice=""

    # Initialize all as unselected
    for ((i=0; i<count; i++)); do
        selected[i]=0
    done

    while true; do
        clear >&2
        echo "" >&2
        echo "$title" >&2
        echo "-----------------------------------------" >&2
        for ((i=0; i<count; i++)); do
            if [[ ${selected[i]} -eq 1 ]]; then
                echo "  [x] $((i+1))) ${items[i]}" >&2
            else
                echo "  [ ] $((i+1))) ${items[i]}" >&2
            fi
        done
        echo "  [a] Select ALL" >&2
        echo "  [n] Select NONE" >&2
        echo "  [q] Quit" >&2
        echo "" >&2
        echo "  (Type number to toggle, Enter to install)" >&2
        read -r -n 1 choice
        echo "" >&2

        if [[ -z "$choice" ]]; then
            break
        elif [[ "$choice" == "q" || "$choice" == "Q" ]]; then
            echo "QUIT"
            return
        elif [[ "$choice" == "a" || "$choice" == "A" ]]; then
            for ((i=0; i<count; i++)); do
                selected[i]=1
            done
        elif [[ "$choice" == "n" || "$choice" == "N" ]]; then
            for ((i=0; i<count; i++)); do
                selected[i]=0
            done
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
            local idx=$((choice - 1))
            if [[ ${selected[idx]} -eq 1 ]]; then
                selected[idx]=0
            else
                selected[idx]=1
            fi
        fi
    done

    # Return selected indices
    local result=()
    for ((i=0; i<count; i++)); do
        if [[ ${selected[i]} -eq 1 ]]; then
            result+=("$((i+1))")
        fi
    done
    echo "${result[@]}"
}
