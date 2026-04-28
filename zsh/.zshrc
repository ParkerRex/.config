# zsh options
setopt HIST_IGNORE_ALL_DUPS
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Custom zsh
[ -f "$HOME/.config/zsh/custom.zsh" ] && source "$HOME/.config/zsh/custom.zsh"

# Aliases
[ -f "$HOME/.config/zsh/aliases.zsh" ] && source "$HOME/.config/zsh/aliases.zsh"

# Work machine-local overrides
[ -f "$HOME/.config/zsh/work.zsh" ] && source "$HOME/.config/zsh/work.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.go/bin:$HOME/go/bin:$PATH"
export PATH="$PATH:/usr/local/share/dotnet:$HOME/.dotnet"

[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

export OLLAMA_API_BASE="${OLLAMA_API_BASE:-http://127.0.0.1:11434}"

if command -v gpgconf >/dev/null 2>&1; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpgconf --launch gpg-agent >/dev/null 2>&1 || true
fi

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
elif command -v brew >/dev/null 2>&1 && [ -s "$(brew --prefix nvm 2>/dev/null)/nvm.sh" ]; then
  mkdir -p "$NVM_DIR"
  source "$(brew --prefix nvm)/nvm.sh"
fi
if command -v nvm >/dev/null 2>&1; then
  nvm_default="${NVM_DEFAULT_VERSION:-default}"
  nvm use "$nvm_default" >/dev/null 2>&1 || true
  if [ -n "${NVM_BIN:-}" ]; then
    path=("$NVM_BIN" ${path:#$NVM_BIN})
  fi
fi
typeset -U path PATH

for stale in /opt/homebrew/lib/node_modules/@openai/codex/node_modules/@vscode/ripgrep/bin \
             /usr/local/lib/node_modules/@openai/codex/node_modules/@vscode/ripgrep/bin; do
  path=(${path:#$stale})
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Machine-local shell config and secrets stay out of the repo.
[ -f "$HOME/.config/zsh/local.zsh" ] && source "$HOME/.config/zsh/local.zsh"
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
