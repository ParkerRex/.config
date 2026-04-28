# Repo Architecture

## Purpose

This repo is the source of truth for a personal `~/.config` setup on macOS. It is not a single app. Most changes either:

- update a source config file that gets symlinked into `$HOME`
- change a bootstrap script that installs or configures the machine
- add app-specific state or tooling that should stay repo-local

## Operating Model

The repo is checked out at `~/.config`. Managed files are linked into their final locations through [`symlinks.conf`](../symlinks.conf) and [`scripts/symlinks.sh`](../scripts/symlinks.sh).

That means the safe mental model is:

1. Edit the file in this repo.
2. Confirm whether it is directly read from `~/.config/...` or symlinked somewhere else.
3. Only change `symlinks.conf` when the destination path changes or a new managed config is introduced.

## Bootstrap Flow

The current bootstrap path is:

1. [`scripts/prerequisites.sh`](../scripts/prerequisites.sh)
2. [`scripts/brew-install-custom.sh`](../scripts/brew-install-custom.sh)
3. [`scripts/symlinks.sh --create`](../scripts/symlinks.sh)
4. [`scripts/osx-defaults.sh`](../scripts/osx-defaults.sh)

There is no canonical root `install.sh` anymore.

## Directory Ownership

### Core interactive environment

- `zsh/`: shell startup, aliases, completions
- `starship/`: prompt configuration
- `ghostty/`, `kitty/`, `tmux/`: terminal emulator and session management
- `nvim/`, `vim/`, `vscode/`, `cursor/`, `zed/`: editor configuration
- `fonts/`: font install docs and private-font staging conventions

### macOS interaction layer

- `karabiner/`: keyboard remaps and app/window launcher behavior
- `rectangle/`: window sizing and movement presets
- `macos/`: reference docs and defaults scripts

### Package and machine bootstrap

- `homebrew/`: Brewfile plus custom casks/formulae
- `scripts/`: setup, defaults, symlink, shell sanity, and maintenance helpers

### App-specific configuration

- `ranger/`, `dbeaver/`, `iterm/`, `opencode/`, `amp/`, `eza/`
- These are usually isolated. Avoid cross-directory refactors unless the bootstrap or symlink contract changed.

### Likely machine-local or high-churn state

- `gws/`, `mole/`, `flutter/`, `agents/`
- Treat these carefully. Some are tools or caches, some contain credentials or generated state, and some are not part of the main bootstrap path.

### Agent knowledge

- `opencode/skill/`: local agent skills and reference packs that are useful to keep under version control when they encode durable workflow guidance

## Neovim Layout

The Neovim config uses `lazy.nvim`.

- [`nvim/init.lua`](../nvim/init.lua): bootstraps lazy.nvim and global startup behavior
- `nvim/plugin/`: eager runtime config
- `nvim/after/ftplugin/`: per-filetype settings
- `nvim/lua/custom/plugins/`: plugin specs and plugin-specific config
- `nvim/lua/custom/`: shared utilities and non-plugin modules

When debugging behavior, search `nvim/plugin/`, `nvim/after/`, and `nvim/lua/custom/plugins/` before assuming a plugin default.

## Change Boundaries

- If a change affects the machine bootstrap flow, update `README.md` and the relevant docs in `docs/`.
- If a change affects linked config paths, update `symlinks.conf`.
- If a change only affects one app, keep the diff inside that app directory whenever possible.
- Avoid bundling generated backups, secrets, token files, or licensed font
  binaries into generic cleanup commits.

## Agent Notes

- Check `git status` before editing. This repo often has unrelated local machine changes.
- Treat deleted app configs or backups as intentional only after confirming they are not generated churn.
- Prefer documenting folder ownership and scripts over trying to normalize every legacy directory in one pass.
