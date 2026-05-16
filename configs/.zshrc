# ==========================================
# Zsh Configuration
# ==========================================

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Plugins
plugins=(
    git
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# ==========================================
# Aliases
# ==========================================
[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

# ==========================================
# General Settings
# ==========================================

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Auto cd
setopt AUTO_CD

# Correct commands
setopt CORRECT

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ==========================================
# Editor
# ==========================================
export EDITOR="vim"
export VISUAL="vim"

# ==========================================
# Language / Tools
# ==========================================

# Python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# SDKMAN!
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true

# ==========================================
# FZF
# ==========================================
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

# ==========================================
# Prompt
# ==========================================
# Hide user@host if default user
DEFAULT_USER="$USER"
