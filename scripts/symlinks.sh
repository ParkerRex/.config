#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../symlinks.conf"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.config/backups/bootstrap-$(date +%Y%m%d%H%M%S)}"
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $0 [--create] [--delete [--include-files]] [--dry-run] [--backup-dir DIR]

Creates or removes the symlinks described in symlinks.conf.

Create mode is safe for existing files: conflicting files/directories are moved
into a timestamped backup directory before the symlink is created.
EOF
}

expand_path() {
    eval echo "$1"
}

backup_path_for() {
    local target=$1
    local relative
    relative="${target#"$HOME"/}"
    printf '%s/%s' "$BACKUP_DIR" "$relative"
}

move_conflict_to_backup() {
    local target=$1
    local backup
    backup="$(backup_path_for "$target")"

    if $DRY_RUN; then
        warning "Would move existing path to backup: $target -> $backup"
        return 0
    fi

    mkdir -p "$(dirname "$backup")"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
        backup="$backup.$(date +%s)"
    fi
    mv "$target" "$backup"
    warning "Moved existing path to backup: $backup"
}

create_one_link() {
    local source=$1
    local target=$2

    source="$(expand_path "$source")"
    target="$(expand_path "$target")"

    if [ ! -e "$source" ]; then
        warning "Source path not found, skipping: $source"
        return 0
    fi

    if [ "$source" = "$target" ]; then
        success "Already managed in place: $target"
        return 0
    fi

    if [ -L "$target" ]; then
        local current_target
        current_target="$(readlink "$target")"
        if [ "$current_target" = "$source" ]; then
            success "Symlink already correct: $target"
            return 0
        fi
        move_conflict_to_backup "$target"
    elif [ -e "$target" ]; then
        move_conflict_to_backup "$target"
    fi

    if $DRY_RUN; then
        info "Would create symlink: $target -> $source"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    success "Created symlink: $target -> $source"
}

create_symlinks() {
    if [ ! -f "$CONFIG_FILE" ]; then
        die "Configuration file not found: $CONFIG_FILE"
    fi

    info "Creating symbolic links..."
    while IFS=: read -r source target || [ -n "$source" ]; do
        if [[ -z "${source:-}" || -z "${target:-}" || "$source" == \#* ]]; then
            continue
        fi
        create_one_link "$source" "$target"
    done <"$CONFIG_FILE"
}

delete_symlinks() {
    if [ ! -f "$CONFIG_FILE" ]; then
        die "Configuration file not found: $CONFIG_FILE"
    fi

    info "Deleting symbolic links..."
    while IFS=: read -r _ target || [ -n "$target" ]; do
        if [[ -z "${target:-}" || "$target" == \#* ]]; then
            continue
        fi

        target="$(expand_path "$target")"
        if [ -L "$target" ]; then
            if $DRY_RUN; then
                info "Would unlink: $target"
            else
                unlink "$target"
                success "Deleted symlink: $target"
            fi
        elif [ "${include_files:-false}" = true ] && [ -f "$target" ]; then
            if $DRY_RUN; then
                info "Would delete file: $target"
            else
                rm "$target"
                success "Deleted file: $target"
            fi
        else
            warning "Not a managed symlink: $target"
        fi
    done <"$CONFIG_FILE"
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    action=""
    include_files=false

    while [ "$#" -gt 0 ]; do
        case "$1" in
        --create|--delete)
            action="$1"
            ;;
        --include-files)
            include_files=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --backup-dir)
            shift
            BACKUP_DIR="${1:?Missing backup directory}"
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

    case "$action" in
    --create)
        create_symlinks
        ;;
    --delete)
        delete_symlinks
        ;;
    *)
        usage
        exit 1
        ;;
    esac
fi
