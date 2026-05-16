# My Shell Config

Development environment setup for **Arch Linux**, **Debian/Ubuntu**, and **macOS**.

## Quick Start

```bash
./install.sh
```

This launches an interactive menu where you can install components individually or all at once.

## Components

| # | Component | Description |
|---|-----------|-------------|
| 1 | Base packages | git, curl, wget, jq, build tools |
| 2 | Zsh | Shell + Oh My Zsh with plugins |
| 3 | Docker | Engine + Compose |
| 4 | Python | pyenv for version management |
| 5 | Node.js | nvm for version management |
| 6 | Java | SDKMAN! for JDK + build tools |
| 7 | Vim | Editor + vim-plug plugins |
| 8 | Extras | fzf, bat, eza, ripgrep, fd, lazygit, btop |
| 9 | AI Tools | GitHub Copilot CLI, opencode, Cursor (optional) |
| 10 | IDE Tools | VS Code, Neovim (optional) |

## Supported OS

- **Arch Linux** (pacman + yay for AUR)
- **Debian / Ubuntu** (apt)
- **macOS** (Homebrew)

## Manual Setup

You can also run individual scripts:

```bash
bash scripts/01-base.sh
bash scripts/02-zsh.sh
bash scripts/03-docker.sh
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
