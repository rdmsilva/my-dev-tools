# Repository Guidelines

## Project Structure & Module Organization

Bash toolkit that sets up development environments on **Arch Linux**, **Debian/Ubuntu**, and **macOS**. `install.sh` is the entry point and requires `gum` (installed first via `ensure_gum`; the script exits with an error if `gum` can't be installed — there is no non-gum fallback). It shows a single-select `gum choose` main menu (loops until "🚪 Exit" or Esc) and dispatches via `run_component` to scripts under `scripts/<category>/<NN>-<name>.sh` — base, shell, containers, languages, editors, terminal, ai. Components with multiple installable options (`base/01-base.sh`, `languages/04-python.sh` for pyenv/uv, `ai/09-ai-tools.sh`, `editors/10-ide.sh`) open their own `gum_multi_select` submenu instead of installing directly; these run via `run_script` (no spinner, so the interactive submenu works) while single-action components run via `run_script_with_spinner` (gum spinner). `base/01-base.sh` shows a flat menu with "Base system packages" plus every individual extra tool (fzf, bat, eza, ripgrep, fd, htop, btop, ag, tree, tldr, kitty, lazygit), each item prefixed with a short description (e.g. "Fuzzy finder — fzf"); `gum choose --no-limit`'s built-in Ctrl+A selects all, so there's no separate "install all" menu entry. It `source`s `terminal/08-extras.sh` to reuse its `install_*` functions and `EXTRA_TOOLS_MENU` array rather than duplicating them. `terminal/08-extras.sh` guards its own interactive menu with `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` so sourcing it only defines functions, while running it directly (`./scripts/terminal/08-extras.sh`) still shows its own extras-only submenu. Every submenu-having script (and `install.sh`'s `run_script`/main loop) calls `clear` on entering and leaving, so the screen resets between the main menu and each submenu. `configs/` holds dotfiles (`.zshrc`, `.zsh_aliases`, `.gitconfig`, `.vimrc`) that scripts symlink into `$HOME` via `link_config` (prompts before backing up an existing file with a timestamp suffix).

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
2. Add its label to **both** the `MENU_ITEMS` array and the `run_component` case in `install.sh` — the strings must match exactly, including the emoji prefix. Use `run_script_with_spinner` for a direct install, or `run_script` if the component opens its own `gum_multi_select` submenu.
3. Add a row to the README component table.

## Commit Guidelines

Conventional-commit style with imperative descriptions, e.g. `feat: add multi-select menu and organize scripts by category`.
