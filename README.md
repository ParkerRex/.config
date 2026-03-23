# Dotfiles

Personal macOS and CLI configuration, centered around a symlinked `~/.config` checkout.

![screenshot](img/nvim-demo.png)

## What This Repo Owns

- Shell: `zsh/`, `starship/`
- Editors: `nvim/`, `vim/`
- Terminal + multiplexing: `ghostty/`, `kitty/`, `tmux/`
- Window management: `karabiner/`, `rectangle/`
- Package/bootstrap scripts: `homebrew/`, `scripts/`, `macos/`
- App-specific config: `ranger/`, `dbeaver/`, `iterm/`, `cursor/`, `opencode/`

The source of truth for what gets linked into `$HOME` is [`symlinks.conf`](symlinks.conf).

## Bootstrap

There is no root `install.sh`. The current setup flow is script-based:

```bash
./scripts/prerequisites.sh
./scripts/brew-install-custom.sh
./scripts/symlinks.sh --create
./scripts/osx-defaults.sh
```

Use these in order on a fresh macOS machine:

1. `prerequisites.sh` installs Xcode CLI tools and Homebrew.
2. `brew-install-custom.sh` installs custom formulae/casks and optionally the main Brew bundle.
3. `symlinks.sh --create` links the managed config files into `$HOME` and app support directories.
4. `osx-defaults.sh` applies Finder, Dock, Trackpad, and Rectangle defaults.

To remove the managed links later:

```bash
./scripts/symlinks.sh --delete
```

## Git Workflow

This repo now includes a repo-local conventional commit workflow:

```bash
./scripts/setup-git-hooks.sh
./scripts/git-commit.sh docs "document the dotfiles bootstrap flow"
```

- `setup-git-hooks.sh` sets `core.hooksPath` to `.githooks` for this repo.
- `.githooks/commit-msg` enforces conventional commit headers.
- `git-commit.sh` builds commit messages, supports optional bodies, and infers a scope from staged paths when it can.

More detail lives in [`docs/git-workflow.md`](docs/git-workflow.md).

## Repo Guide

Start here when you need to change or audit the repo:

- [`docs/architecture.md`](docs/architecture.md) explains the symlink model, directory ownership, and change boundaries.
- [`docs/dev-environment.md`](docs/dev-environment.md) captures local CLI/runtime assumptions.
- [`macos/README.md`](macos/README.md) is older reference material for machine bootstrap history, not the current primary flow.

## Adding or Changing Config

1. Change the source file inside this repo.
2. If the config must be linked into another location, update [`symlinks.conf`](symlinks.conf).
3. If setup behavior changed, update the relevant script in `scripts/` and the docs above.
4. Keep machine-local secrets, tokens, caches, and generated app state out of generic cleanup commits unless the change is intentional.

## High-Signal Directories

- `nvim/` is a lazy.nvim-based Neovim config with custom plugin specs under `lua/custom/plugins/`.
- `ghostty/`, `kitty/`, and `tmux/` define the interactive terminal stack.
- `karabiner/` plus `rectangle/` implement the keyboard-driven window/app switching workflow.
- `homebrew/` stores the Brew bundle plus custom casks/formulae.
- `scripts/` holds the repeatable machine bootstrap and maintenance scripts.
