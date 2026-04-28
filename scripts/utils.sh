#!/usr/bin/env bash

if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    default_color=$(tput sgr 0)
    red="$(tput setaf 1)"
    yellow="$(tput setaf 3)"
    green="$(tput setaf 2)"
    blue="$(tput setaf 4)"
else
    default_color=""
    red=""
    yellow=""
    green=""
    blue=""
fi

info() {
    printf "%s==> %s%s\n" "$blue" "$1" "$default_color"
}

success() {
    printf "%s==> %s%s\n" "$green" "$1" "$default_color"
}

error() {
    printf "%s==> %s%s\n" "$red" "$1" "$default_color"
}

warning() {
    printf "%s==> %s%s\n" "$yellow" "$1" "$default_color"
}

die() {
    error "$1"
    exit "${2:-1}"
}

repo_root() {
    cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}
