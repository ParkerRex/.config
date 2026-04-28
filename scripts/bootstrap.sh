#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

RUN_BREW=true
RUN_NVIM=true
RUN_OSX=false
RUN_CHECK=true
YES=false
STRICT_NVIM=false

usage() {
    cat <<EOF
Usage: $0 [--yes] [--skip-brew] [--skip-nvim] [--apply-osx-defaults] [--skip-check] [--strict-nvim]

One-command macOS bootstrap for this dotfiles repo.

Default behavior:
  1. Verify Command Line Tools and Homebrew.
  2. Install homebrew/Brewfile.
  3. Install private fonts when present.
  4. Create managed symlinks, backing up conflicts first.
  5. Try a headless lazy.nvim plugin sync.
  6. Run smoke checks.

Options:
  --yes                 Non-interactive mode.
  --skip-brew           Do not install Brewfile dependencies.
  --skip-nvim           Do not run lazy.nvim sync.
  --apply-osx-defaults  Apply macOS Finder/Dock/Rectangle defaults.
  --skip-check          Do not run the final health check.
  --strict-nvim         Treat lazy.nvim sync failures as fatal.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    --yes|-y)
        YES=true
        ;;
    --skip-brew)
        RUN_BREW=false
        ;;
    --skip-nvim)
        RUN_NVIM=false
        ;;
    --apply-osx-defaults)
        RUN_OSX=true
        ;;
    --skip-check)
        RUN_CHECK=false
        ;;
    --strict-nvim)
        STRICT_NVIM=true
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        die "Unknown argument: $1"
        ;;
    esac
    shift
done

if [ "$(uname -s)" != "Darwin" ]; then
    die "This bootstrap is for macOS. Detected: $(uname -s)"
fi

if [ "$REPO_DIR" != "$HOME/.config" ]; then
    die "This repo must be checked out at ~/.config. Current path: $REPO_DIR"
fi

run_step() {
    local label=$1
    shift
    info "$label"
    "$@"
}

ensure_xdg_dirs() {
    mkdir -p "$HOME/.cache" "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/state" "$HOME/Developer"
    mkdir -p "$HOME/.config/backups" "$HOME/.nvm"
}

setup_local_files() {
    local local_zsh="$HOME/.config/zsh/local.zsh"
    if [ ! -f "$local_zsh" ]; then
        cat >"$local_zsh" <<'EOF'
# Machine-local shell customizations.
# Keep secrets and machine-specific paths here; this file is gitignored.
#
# export GEMINI_API_KEY="..."
# export THINGS_AUTH_TOKEN="..."
# export ADOBE_ILLUSTRATOR_MCP_BEARER_TOKEN="..."
EOF
        success "Created local shell override: $local_zsh"
    fi
}

setup_node_default() {
    if ! command -v zsh >/dev/null 2>&1; then
        return 0
    fi

    zsh -lc '
      source "$HOME/.config/zsh/.zshenv" 2>/dev/null || true
      source "$HOME/.config/zsh/.zshrc" 2>/dev/null || true
      if command -v nvm >/dev/null 2>&1; then
        nvm install "${NVM_DEFAULT_VERSION:-lts/*}" >/dev/null
        nvm alias default "${NVM_DEFAULT_VERSION:-lts/*}" >/dev/null
      fi
    ' || warning "NVM default setup failed; you can retry with: nvm install --lts && nvm alias default node"
}

sync_neovim() {
    if ! command -v nvim >/dev/null 2>&1; then
        warning "nvim is not installed yet; skipping lazy.nvim sync"
        return 0
    fi

    local cmd=(nvim --headless "+Lazy! sync" +qa)
    if "${cmd[@]}"; then
        success "lazy.nvim sync completed"
    elif $STRICT_NVIM; then
        die "lazy.nvim sync failed"
    else
        warning "lazy.nvim sync failed. Open nvim and run :Lazy sync after reviewing the message above."
    fi
}

run_step "Preparing directories..." ensure_xdg_dirs
run_step "Checking prerequisites..." "$SCRIPT_DIR/prerequisites.sh"

if $RUN_BREW; then
    if $YES; then
        run_step "Installing Homebrew bundle..." "$SCRIPT_DIR/brew-install-custom.sh" --yes
    else
        run_step "Installing Homebrew bundle..." "$SCRIPT_DIR/brew-install-custom.sh"
    fi
fi

run_step "Creating local-only config placeholders..." setup_local_files
run_step "Installing private fonts..." "$SCRIPT_DIR/install-private-fonts.sh"
run_step "Creating managed symlinks..." "$SCRIPT_DIR/symlinks.sh" --create

if $RUN_BREW; then
    run_step "Configuring default Node version..." setup_node_default
fi

if $RUN_NVIM; then
    run_step "Syncing Neovim plugins..." sync_neovim
fi

if $RUN_OSX; then
    run_step "Applying macOS defaults..." "$SCRIPT_DIR/osx-defaults.sh"
else
    warning "Skipping macOS defaults. Re-run with --apply-osx-defaults to apply Finder/Dock/Rectangle defaults."
fi

if $RUN_CHECK; then
    run_step "Running final checks..." "$SCRIPT_DIR/check-shell.sh"
fi

success "Bootstrap complete. Restart your terminal or run: exec zsh -l"
