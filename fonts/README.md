# Fonts

This directory tracks font installation instructions, not licensed font binaries.

## Berkeley Mono

Berkeley Mono is a licensed typeface. Keep the actual `.otf` files in:

```text
fonts/private/berkeley-mono/
```

That directory is gitignored so the public dotfiles repo does not redistribute
the font files.

Install private fonts from this repo with:

```bash
./scripts/install-private-fonts.sh
```
