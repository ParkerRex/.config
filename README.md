# Dotfiles

Personal macOS and CLI configuration. The repo is designed to live at
`~/.config`; scripts then link the small number of files that macOS or tools
expect elsewhere.

![screenshot](img/nvim-demo.png)

## Fresh Machine

Run this on a new Mac:

```bash
xcode-select --install
git clone https://github.com/ParkerRex/.config.git ~/.config
cd ~/.config
./scripts/bootstrap.sh --yes
```

That command installs Homebrew dependencies, creates safe symlinks, backs up
conflicting existing files, creates a local-only shell override file, attempts a
private font install, attempts a Neovim plugin sync, and runs smoke checks.

For the full operator/agent flow, see
[`docs/fresh-machine-runbook.md`](docs/fresh-machine-runbook.md).

## Common Follow-Ups

Reload the shell:

```bash
exec zsh -l
```

Apply macOS Finder/Dock/Rectangle defaults:

```bash
~/.config/scripts/bootstrap.sh --yes --apply-osx-defaults
```

Retry only Homebrew:

```bash
~/.config/scripts/brew-install-custom.sh --yes
```

Retry only Neovim plugins:

```bash
nvim
:Lazy sync
```

Machine-local secrets belong in `~/.config/zsh/local.zsh` or `~/.env`, not in
tracked dotfiles.

## What This Repo Owns

- Shell: `zsh/`, `starship/`
- Editors: `nvim/`, `vim/`, `vscode/`, `cursor/`, `zed/`
- Fonts: `fonts/` tracks install instructions; licensed binaries stay in
  gitignored `fonts/private/`
- Terminal + multiplexing: `ghostty/`, `kitty/`, `tmux/`
- Window management: `karabiner/`, `rectangle/`
- Package/bootstrap scripts: `homebrew/`, `scripts/`, `macos/`
- App-specific config: `ranger/`, `dbeaver/`, `iterm/`, `opencode/`

The source of truth for managed links is [`symlinks.conf`](symlinks.conf).

## Maintenance

Run checks after edits:

```bash
./scripts/check-shell.sh
```

Set up conventional commit hooks:

```bash
./scripts/setup-git-hooks.sh
./scripts/git-commit.sh docs "document setup flow"
```

More repo detail lives in:

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/dev-environment.md`](docs/dev-environment.md)
- [`docs/git-workflow.md`](docs/git-workflow.md)
