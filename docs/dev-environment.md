# Dev Environment (Personal)

## Tooling (Node + Bun)

- Node runtime is managed by nvm (default LTS is v24.12.0).
- Global CLIs come from bun. Install with `bun add -g <pkg>`.
- Avoid global installs via npm/pnpm/yarn/brew to prevent PATH conflicts.
- CLI names: `opencode` (from `opencode-ai`), `claude`, `codex`.
- Update path sanity: `which node` and `type -a opencode claude codex`.

## Sanity Checks

```bash
which node && node -v
which npm && npm -v
type -a codex claude opencode
```

## Common Fixes

- If you see update loops: run `type -a <cli>` to find duplicates and remove the non-bun copies.
- If scripts use the wrong Node: ensure `~/.nvm/versions/node/v24.12.0/bin` is in PATH for non-interactive shells.
