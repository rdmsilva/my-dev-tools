# Repository Guidelines

## Project Structure & Module Organization

Bash toolkit that sets up development environments on **Arch Linux**, **Debian/Ubuntu**, and **macOS**. `install.sh` is the entry point: it shows a gum-powered multi-select menu (installing `gum` first via `ensure_gum`; falls back to the plain `multi_select_menu` if gum is unavailable) and dispatches to component scripts under `scripts/<category>/<NN>-<name>.sh` — base, shell, containers, languages, editors, terminal, ai. `scripts/editors/10-ide.sh` exists but is **not** in the installer menu; run it directly. `configs/` holds dotfiles (`.zshrc`, `.zsh_aliases`, `.gitconfig`, `.vimrc`) that scripts symlink into `$HOME` via `link_config` (prompts before backing up an existing file with a timestamp suffix).

## Build, Test, and Development Commands

```bash
./install.sh                                    # interactive installer
./scripts/base/01-base.sh                       # run a single component
bash -c 'source scripts/utils.sh && detect_os'  # check OS detection (arch|debian|macos|unknown)
```

There is no test suite or linter config.

## Coding Style & Naming Conventions

Every component script starts with this boilerplate:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
OS=$(detect_os)
```

Branch OS-specific logic with `case "$OS"` and use the helpers from `scripts/utils.sh`:

- `pkg_install <pkg...>` — pacman (`--noconfirm --needed`) / apt / brew
- `aur_install <pkg...>` — AUR via yay (Arch only; auto-installs yay)
- `command_exists <cmd>` — skip work when a tool is already installed (scripts are idempotent)
- `confirm <msg>` / `link_config <src> <dest>` — prompts and dotfile symlinks
- `log_info` / `log_ok` / `log_warn` / `log_error` — colored, emoji-prefixed output (emoji constants `E_*` defined in `utils.sh`)

## Adding a New Component

1. Create `scripts/<category>/<NN>-<name>.sh` with the boilerplate above.
2. Add its label to **both** the `gum choose` list and the `install_selected` case in `install.sh` — the strings must match exactly, including the emoji prefix.
3. Add a row to the README component table.

## Commit Guidelines

Conventional-commit style with imperative descriptions, e.g. `feat: add multi-select menu and organize scripts by category`.
