#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

usage() {
    cat <<'EOF'
Usage:
  ./scripts/git-commit.sh <type> <summary> [--scope <scope>] [--body <text>] [--breaking] [--dry-run]

Examples:
  ./scripts/git-commit.sh fix "remove env cloaking from Neovim" --scope nvim
  ./scripts/git-commit.sh docs "document the dotfiles bootstrap flow" --body "Add repo map and git workflow docs."
EOF
}

valid_type() {
    case "$1" in
        build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)
            return 0
            ;;
    esac

    return 1
}

infer_scope() {
    local inferred_scope=""

    while IFS= read -r path; do
        [ -n "$path" ] || continue

        local scope="${path%%/*}"
        if [[ "$path" != */* ]]; then
            scope="repo"
        fi

        if [ -z "$inferred_scope" ]; then
            inferred_scope="$scope"
            continue
        fi

        if [ "$inferred_scope" != "$scope" ]; then
            return 0
        fi
    done < <(git diff --cached --name-only --diff-filter=ACMR)

    if [ -n "$inferred_scope" ]; then
        printf '%s\n' "$inferred_scope"
    fi
}

ensure_hooks_installed() {
    local current_hooks_path
    current_hooks_path="$(git config --get core.hooksPath || true)"

    if [ "$current_hooks_path" != ".githooks" ]; then
        warning "Repo-local hooks are not enabled."
        info "Run: git config core.hooksPath .githooks"
    fi
}

if [ "$#" -lt 2 ]; then
    usage
    exit 1
fi

type="$1"
summary="$2"
shift 2

if ! valid_type "$type"; then
    error "Invalid type: $type"
    usage
    exit 1
fi

scope=""
breaking=false
dry_run=false
declare -a bodies=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --scope)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error "--scope requires a value"
                exit 1
            fi
            scope="$2"
            shift 2
            ;;
        --body)
            if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
                error "--body requires a value"
                exit 1
            fi
            bodies+=("$2")
            shift 2
            ;;
        --breaking)
            breaking=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            error "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$scope" ]; then
    scope="$(infer_scope)"
fi

header="$type"

if [ -n "$scope" ]; then
    header+="($scope)"
fi

if [ "$breaking" = true ]; then
    header+="!"
fi

header+=": $summary"

ensure_hooks_installed

if [ "$dry_run" = true ]; then
    printf '%s\n' "$header"
    if [ "${#bodies[@]}" -gt 0 ]; then
        for body in "${bodies[@]}"; do
            printf '\n%s\n' "$body"
        done
    fi
    exit 0
fi

if git diff --cached --quiet; then
    error "No staged changes. Stage files before committing."
    exit 1
fi

commit_args=(-m "$header")

if [ "${#bodies[@]}" -gt 0 ]; then
    for body in "${bodies[@]}"; do
        commit_args+=(-m "$body")
    done
fi

git commit "${commit_args[@]}"
