# Fresh Machine Runbook

This is the canonical setup path for a new macOS machine. It is written for both
humans and agents: run commands in order, verify each checkpoint, then move on.

## Ground Rules

- The repo must live at `~/.config`.
- Keep secrets out of git. Use `~/.config/zsh/local.zsh` or `~/.env`.
- Existing dotfiles are backed up before symlinks are created.
- The main setup command is idempotent; rerunning it should be normal.

## One-Command Setup

```bash
xcode-select --install
git clone https://github.com/ParkerRex/.config.git ~/.config
cd ~/.config
./scripts/bootstrap.sh --yes
```

Expected result:

- Homebrew is installed or detected.
- `homebrew/Brewfile` dependencies are installed.
- `~/.zshenv` and `~/.zshrc` point at this repo.
- `~/.config/zsh/local.zsh` exists for secrets and machine-local paths.
- Private fonts are installed when present under `fonts/private/`.
- Neovim plugins are attempted with `Lazy sync`.
- `./scripts/check-shell.sh` passes or prints concrete next steps.

## Bootstrap Options

```bash
./scripts/bootstrap.sh --help
```

Useful modes:

- `--yes`: non-interactive setup.
- `--skip-brew`: do not install Homebrew dependencies.
- `--skip-nvim`: do not run Neovim plugin sync.
- `--apply-osx-defaults`: apply Finder, Dock, keyboard, and Rectangle defaults.
- `--strict-nvim`: fail the bootstrap if `Lazy sync` fails.

## Manual Recovery Steps

Run only prerequisites:

```bash
~/.config/scripts/prerequisites.sh
```

Run only Homebrew:

```bash
~/.config/scripts/brew-install-custom.sh --yes
```

Run only symlink creation:

```bash
~/.config/scripts/symlinks.sh --create
```

Install only private fonts:

```bash
~/.config/scripts/install-private-fonts.sh
```

Run only checks:

```bash
~/.config/scripts/check-shell.sh
```

## Secrets And Local State

`bootstrap.sh` creates `~/.config/zsh/local.zsh` if it is missing. Put local
tokens and machine-specific PATH values there:

```zsh
export GEMINI_API_KEY="..."
export THINGS_AUTH_TOKEN="..."
export ADOBE_ILLUSTRATOR_MCP_BEARER_TOKEN="..."
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
```

The repo includes `zsh/local.zsh.example` as a template. The real
`zsh/local.zsh`, `.env`, and `*.local` files are gitignored.

## Neovim

The config is lazy.nvim-based. The bootstrap tries:

```bash
nvim --headless "+Lazy! sync" +qa
```

If that fails, open Neovim normally and run:

```vim
:Lazy sync
```

If old disabled plugins are still on disk:

```vim
:Lazy clean
```

Supermaven is disabled by default in `nvim/lua/custom/plugins/completion.lua`
because it prompts for account setup and interrupts fresh machine bootstrap.
Regular `nvim-cmp` autocomplete stays enabled.

## Homebrew Troubleshooting

If Homebrew says directories are not writable, fix ownership:

```bash
sudo chown -R "$USER" /opt/homebrew "$HOME/Library/Caches/Homebrew" "$HOME/Library/Logs/Homebrew"
chmod -R u+w /opt/homebrew "$HOME/Library/Caches/Homebrew" "$HOME/Library/Logs/Homebrew"
```

If `brew bundle` fails, rerun with output visible:

```bash
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install --file ~/.config/homebrew/Brewfile
```

The Brewfile should be the source of truth for normal setup. The
`homebrew/custom-*` directories are legacy escape hatches and are not installed
by default.

## Symlink Backups

When a target file already exists, `scripts/symlinks.sh --create` moves it into:

```text
~/.config/backups/bootstrap-YYYYMMDDHHMMSS/
```

Then it creates the managed symlink. This makes reruns safe and avoids losing an
existing `~/.zshrc`, `~/.vimrc`, or app config.

## Agent Checklist

1. Confirm repo path:

   ```bash
   test "$(pwd)" = "$HOME/.config"
   ```

2. Run bootstrap:

   ```bash
   ./scripts/bootstrap.sh --yes
   ```

3. Run checks:

   ```bash
   ./scripts/check-shell.sh
   ```

4. Inspect failures before changing files:

   ```bash
   brew bundle check --file ~/.config/homebrew/Brewfile
   nvim --headless -u NONE +qa
   ```

5. Never commit secrets, `zsh/local.zsh`, `.env`, licensed font binaries, app
   caches, logs, or backup directories.
