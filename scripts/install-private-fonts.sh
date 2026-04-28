#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

PRIVATE_FONT_DIR="${DOTFILES_PRIVATE_FONT_DIR:-$REPO_DIR/fonts/private}"
BERKELEY_MONO_DIR="$PRIVATE_FONT_DIR/berkeley-mono"
FONT_TARGET_DIR="${DOTFILES_FONT_TARGET_DIR:-$HOME/Library/Fonts}"
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $0 [--dry-run]

Installs private, gitignored font files into the macOS user font directory.

Expected Berkeley Mono source directory:
  $BERKELEY_MONO_DIR
EOF
}

install_font_file() {
    local source=$1
    local target="$FONT_TARGET_DIR/$(basename "$source")"

    if [ -e "$target" ] && cmp -s "$source" "$target"; then
        success "Font already installed: $(basename "$source")"
        return 0
    fi

    if $DRY_RUN; then
        info "Would install font: $source -> $target"
        return 0
    fi

    mkdir -p "$FONT_TARGET_DIR"
    cp "$source" "$target"
    success "Installed font: $(basename "$source")"
}

install_berkeley_mono() {
    if [ ! -d "$BERKELEY_MONO_DIR" ]; then
        warning "Berkeley Mono source directory missing, skipping: $BERKELEY_MONO_DIR"
        return 0
    fi

    shopt -s nullglob
    local font_files=("$BERKELEY_MONO_DIR"/*.otf "$BERKELEY_MONO_DIR"/*.ttf)
    shopt -u nullglob

    if [ "${#font_files[@]}" -eq 0 ]; then
        warning "No Berkeley Mono font files found in: $BERKELEY_MONO_DIR"
        return 0
    fi

    for font_file in "${font_files[@]}"; do
        install_font_file "$font_file"
    done
}

while [ "$#" -gt 0 ]; do
    case "$1" in
    --dry-run)
        DRY_RUN=true
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

install_berkeley_mono
