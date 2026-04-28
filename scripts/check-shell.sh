#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

status=0

fail() {
    error "$1"
    status=1
}

check_link() {
    local target=$1
    local expected=$2

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        fail "$target is missing"
        return
    fi

    if [ "$target" = "$expected" ]; then
        success "$target is managed in place"
        return
    fi

    if [ ! -L "$target" ]; then
        fail "$target exists but is not a symlink"
        return
    fi

    local actual
    actual="$(readlink "$target")"
    if [ "$actual" = "$expected" ]; then
        success "$target -> $expected"
    else
        fail "$target points to $actual, expected $expected"
    fi
}

check_command() {
    local command_name=$1
    if command -v "$command_name" >/dev/null 2>&1; then
        success "Found command: $command_name"
    else
        fail "Missing command: $command_name"
    fi
}

info "Checking shell links..."
check_link "$HOME/.zshenv" "$HOME/.config/zsh/.zshenv"
check_link "$HOME/.zshrc" "$HOME/.config/zsh/.zshrc"

info "Checking zsh syntax..."
if zsh -n "$REPO_DIR/zsh/.zshenv" "$REPO_DIR/zsh/.zshrc" "$REPO_DIR/zsh/custom.zsh" "$REPO_DIR/zsh/aliases.zsh"; then
    success "zsh files parse"
else
    fail "zsh syntax check failed"
fi

info "Checking expected commands..."
for command_name in brew git nvim rg fzf zoxide starship; do
    check_command "$command_name"
done

if command -v brew >/dev/null 2>&1; then
    info "Checking Brewfile..."
    if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$REPO_DIR/homebrew/Brewfile" >/dev/null; then
        success "Brewfile dependencies are satisfied"
    else
        warning "Brewfile still has missing dependencies. Run: brew bundle install --file ~/.config/homebrew/Brewfile"
    fi
fi

if command -v nvim >/dev/null 2>&1; then
    info "Checking Neovim Lua syntax..."
    if command -v luac >/dev/null 2>&1; then
        if find "$REPO_DIR/nvim" -name '*.lua' -print0 | xargs -0 -n1 luac -p; then
            success "Neovim Lua files parse"
        else
            fail "Neovim Lua syntax check failed"
        fi
    else
        warning "luac not found; skipping Lua syntax check"
    fi
fi

if [ "$status" -eq 0 ]; then
    success "Dotfile checks complete"
else
    error "Dotfile checks found problems"
fi

exit "$status"
