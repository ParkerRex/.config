#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

ensure_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        die "This bootstrap is written for macOS. Detected: $(uname -s)"
    fi
}

install_xcode() {
    ensure_macos
    info "Checking Apple Command Line Tools..."
    if xcode-select -p >/dev/null; then
        success "Command Line Tools are installed"
    else
        warning "Command Line Tools are missing. macOS will open an installer dialog."
        xcode-select --install
        warning "Re-run this script after the installer finishes."
        exit 1
    fi
}

install_homebrew() {
    ensure_macos
    info "Checking Homebrew..."
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew is installed"
    else
        info "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

check_homebrew_writable() {
    if ! command -v brew >/dev/null 2>&1; then
        return 0
    fi

    local prefix cache_dir problem_dirs=()
    prefix="$(brew --prefix)"
    cache_dir="${HOMEBREW_CACHE:-$HOME/Library/Caches/Homebrew}"

    for dir in "$prefix" "$prefix/Cellar" "$prefix/bin" "$prefix/etc" "$prefix/share" "$cache_dir"; do
        if [ -e "$dir" ] && [ ! -w "$dir" ]; then
            problem_dirs+=("$dir")
        fi
    done

    if [ "${#problem_dirs[@]}" -gt 0 ]; then
        warning "Some Homebrew paths are not writable by $USER:"
        printf '  %s\n' "${problem_dirs[@]}"
        warning "Fix with: sudo chown -R $USER ${problem_dirs[*]}"
    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
    check_homebrew_writable
fi
