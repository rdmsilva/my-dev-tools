# My Shell Config

Development environment setup for **Arch Linux**, **Debian/Ubuntu**, and **macOS**.

## Quick Start

```bash
./install.sh
```

This launches an interactive menu (powered by [gum](https://github.com/charmbracelet/gum), auto-installed if missing — **required**, the installer exits if it can't be installed). Navigate with the arrow keys and press **Enter** to pick one component; it installs (or opens a follow-up multi-select submenu, for components with more than one option) and then you're back at the main menu. Pick "🚪 Exit" or press **Esc** to quit.

![Component selection menu](docs/menu-screenshot.png)

## Components

| Component | Description |
|-----------|-------------|
| Base & Extra tools | Pick base packages (git, curl, jq, build tools) and/or individual extras: fzf, bat, eza, ripgrep, fd, htop, btop, ag, tree, tldr, kitty, lazygit — each shown with a short description; Ctrl+A selects all |
| Zsh + Oh My Zsh | Shell with plugins |
| Docker | Engine + Compose |
| Python (pyenv/uv) | Choose pyenv, uv, or both |
| Node.js (nvm) | Version management |
| Java (SDKMAN!) | JDK + build tools |
| Vim + plugins | Editor + vim-plug plugins |
| AI tools | GitHub Copilot CLI, opencode, Cursor, Hermes Agent (choose which) |
| IDE tools | VS Code, Neovim, PyCharm Community, IntelliJ IDEA Community (choose which) |

## Supported OS

- **Arch Linux** (pacman + yay for AUR)
- **Debian / Ubuntu** (apt)
- **macOS** (Homebrew)

## Manual Setup

You can also run individual scripts:

```bash
./scripts/base/01-base.sh
./scripts/shell/02-zsh.sh
./scripts/containers/03-docker.sh
# ... etc
```

## Config Files

Symlinked to your home directory:

- `configs/.zshrc` - Zsh configuration
- `configs/.zsh_aliases` - Custom aliases
- `configs/.gitconfig` - Git configuration template
- `configs/.vimrc` - Vim configuration

## Plugins

### Zsh
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-completions

### Vim
- NERDTree - File explorer
- vim-fugitive - Git integration
- coc.nvim - IntelliSense engine
- vim-airline - Status bar
- vim-surround - Surround text objects
