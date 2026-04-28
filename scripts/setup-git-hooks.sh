#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./scripts/utils.sh
. "$SCRIPT_DIR/utils.sh"

git config core.hooksPath .githooks
success "Configured repo-local git hooks: .githooks"
