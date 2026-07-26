#!/usr/bin/env bash
#
# Utility functions for multi-OS support
#

log_info()  { gum log --level info  "$1"; }
log_ok()    { gum log --level info --level.foreground "10" "✅ $1"; }
log_warn()  { gum log --level warn  "$1"; }
log_error() { gum log --level error "$1"; }

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

# Check/install gum
ensure_gum() {
    if command_exists gum; then
        return
    fi

    local os
    os=$(detect_os)

    case "$os" in
        arch)
            sudo pacman -S --noconfirm --needed gum
            ;;
        debian)
            sudo mkdir -p /etc/apt/keyrings
            sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/charm.gpg --keyserver https://charm.sh/gum.key --recv-keys 2582E0C5
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update
            sudo apt install -y gum
            ;;
        macos)
            brew install gum
            ;;
        *)
            echo "ERROR: Unsupported OS for gum installation"
            return 1
            ;;
    esac

    clear
}

# Styled title banner shown at the top of a menu/submenu
# Usage: gum_title "Line 1" ["Line 2" ...]
gum_title() {
    ensure_gum
    gum style \
        --border double \
        --border-foreground 212 \
        --foreground 212 \
        --align center \
        --width 50 \
        --margin "1 0" \
        --padding "1 4" \
        "$@"
}

# Gum-based multi-select menu
# Usage: gum_multi_select "Title" "Item1" "Item2" "Item3"
# Returns: newline-separated selected items
gum_multi_select() {
    local title="$1"
    shift
    local items=("$@")
    local height=$(( ${#items[@]} + 2 ))

    ensure_gum

    gum choose --no-limit --header "$title" --cursor ">" --height "$height" --selected.foreground="212" "${items[@]}"
}

# Exported so install_* functions can run under `gum spin -- bash -c '...'`
# (a fresh subprocess that doesn't inherit shell functions unless exported).
export -f log_info log_ok log_warn log_error detect_os pkg_install \
    command_exists is_root confirm link_config install_yay aur_install \
    ensure_gum gum_title gum_multi_select
