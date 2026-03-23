# Git Workflow

## Goal

Keep commits small, searchable, and scoped to one config area when possible.

## Conventional Commit Format

Use:

```text
type(scope): summary
```

Examples:

```text
fix(nvim): remove env value cloaking
docs(repo): document the symlink bootstrap flow
chore(git): add repo-local commit hooks
refactor(ghostty): simplify split keybindings
```

Supported types:

- `build`
- `chore`
- `ci`
- `docs`
- `feat`
- `fix`
- `perf`
- `refactor`
- `revert`
- `style`
- `test`

## Recommended Scopes

Use the top-level config area when possible:

- `nvim`
- `ghostty`
- `tmux`
- `zsh`
- `karabiner`
- `rectangle`
- `homebrew`
- `macos`
- `scripts`
- `repo`
- `git`

If a commit truly spans multiple areas, either split it or use a broader scope like `repo`.

## Repo-Local Hook Setup

Enable the repo hooks once per clone:

```bash
./scripts/setup-git-hooks.sh
```

That sets:

```bash
git config core.hooksPath .githooks
```

The current `commit-msg` hook enforces the conventional commit header for normal commits while allowing `Merge`, `Revert`, `fixup!`, and `squash!` commits through.

## Commit Helper

Use the helper when you want the repo to build the header for you:

```bash
./scripts/git-commit.sh fix "remove env value cloaking" --scope nvim
./scripts/git-commit.sh docs "document repo ownership" --body "Add architecture and git workflow docs."
```

Behavior:

- requires staged changes
- infers scope from staged paths when exactly one top-level area is staged
- supports `--body` multiple times
- supports `--breaking` and `--dry-run`

## Practical Rules

- Stage one logical change at a time.
- Do not commit machine-local backup files unless the backup itself is the intended artifact.
- Do not mix secrets, token churn, or generated caches into ordinary config commits.
- If the tree is already dirty, stage only the files for the change you mean to ship.
