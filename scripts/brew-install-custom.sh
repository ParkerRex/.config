#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

FORMULAE_DIR="$SCRIPT_DIR/../homebrew/custom-formulae"
CASKS_DIR="$SCRIPT_DIR/../homebrew/custom-casks"
BREWFILE="$SCRIPT_DIR/../homebrew/Brewfile"

INSTALL_BUNDLE=true
INSTALL_CUSTOM=false
YES=false

usage() {
    cat <<EOF
Usage: $0 [--yes] [--bundle-only] [--custom] [--custom-only] [--check]

Installs the Homebrew bundle used by this dotfiles repo.

Options:
  --yes          Run non-interactively.
  --bundle-only Install only homebrew/Brewfile. This is the default.
  --custom      Also install local formulae/casks from homebrew/custom-*.
  --custom-only Install only local formulae/casks.
  --check       Check whether the Brewfile is satisfied, without installing.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    --yes|-y)
        YES=true
        ;;
    --bundle-only)
        INSTALL_BUNDLE=true
        INSTALL_CUSTOM=false
        ;;
    --custom)
        INSTALL_CUSTOM=true
        ;;
    --custom-only)
        INSTALL_BUNDLE=false
        INSTALL_CUSTOM=true
        ;;
    --check)
        HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$BREWFILE"
        exit $?
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

load_brew_shellenv() {
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

install_custom() {
    local package_name=$1
    local is_cask=$2

    if $is_cask && [ -f "$CASKS_DIR/$package_name.rb" ]; then
        info "Installing custom cask: $package_name"
        brew install --force --cask "$CASKS_DIR/$package_name.rb"
    elif ! $is_cask && [ -f "$FORMULAE_DIR/$package_name.rb" ]; then
        info "Installing custom formula: $package_name"
        brew install "$FORMULAE_DIR/$package_name.rb"
    else
        die "File not found for package: $package_name"
    fi
}

install_custom_formulae() {
    if [ ! -d "$FORMULAE_DIR" ]; then
        return 0
    fi

    local file
    for file in "$FORMULAE_DIR"/*.rb; do
        [ -e "$file" ] || continue
        install_custom "$(basename "${file%.rb}")" false
    done
}

install_custom_casks() {
    if [ ! -d "$CASKS_DIR" ]; then
        return 0
    fi

    local file
    for file in "$CASKS_DIR"/*.rb; do
        [ -e "$file" ] || continue
        install_custom "$(basename "${file%.rb}")" true
    done
}

run_brew_bundle() {
    if [ ! -f "$BREWFILE" ]; then
        die "Brewfile not found: $BREWFILE"
    fi

    export HOMEBREW_NO_AUTO_UPDATE="${HOMEBREW_NO_AUTO_UPDATE:-1}"
    if brew bundle check --file="$BREWFILE"; then
        success "Brewfile dependencies are already satisfied"
    else
        info "Installing missing Brewfile dependencies..."
        brew bundle install --file="$BREWFILE"
    fi
}

if ! command -v brew >/dev/null 2>&1; then
    load_brew_shellenv
fi

if ! command -v brew >/dev/null 2>&1; then
    die "Homebrew is not installed. Run ./scripts/prerequisites.sh first."
fi

if $INSTALL_CUSTOM && ! $YES; then
    warning "Custom formulae/casks are legacy escape hatches and can be slow."
    read -r -p "Install custom formulae/casks too? [y/N] " install_custom_answer
    if [[ ! "$install_custom_answer" =~ ^[Yy]$ ]]; then
        INSTALL_CUSTOM=false
    fi
fi

if $INSTALL_CUSTOM; then
    install_custom_formulae
    install_custom_casks
fi

if $INSTALL_BUNDLE; then
    run_brew_bundle
fi
