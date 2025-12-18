# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a "stow package" that mirrors the home directory structure.

## Stow Architecture

Each package follows the pattern `<package>/.config/<app>/`:
- `nvim/.config/nvim/` → symlinked to `~/.config/nvim`
- `fish/.config/fish/` → symlinked to `~/.config/fish`

### Common Commands

```bash
# Symlink a package (from dotfiles root)
stow -t ~ <package>

# Remove a symlink
stow -t ~ -D <package>

# Re-stow (useful after restructuring)
stow -t ~ -R <package>
```

## Git Commits

Never add co-author lines or AI attribution to commit messages.

## Platform-Specific Patterns

This repository supports both macOS and Linux. Key patterns:

**Fish shell** uses runtime detection:

```fish
if test (uname) = Darwin
    # macOS-specific paths
end
```

**Ghostty** uses separate stow packages with optional config file includes:

- `ghostty/` - shared config (always stow)
- `ghostty-macos/` - macOS-specific (font-size: 14)
- `ghostty-linux/` - Linux-specific (font-size: 12)

Usage: `stow ghostty ghostty-macos` or `stow ghostty ghostty-linux`

## Key Configurations

### Neovim (`nvim/`)
LazyVim-based configuration with 40+ plugin specs in `lua/plugins/`. Notable integrations: Claude Code, Copilot, Aider, vim-slime (REPL), Quarto, R.nvim.

Plugin configuration files are in `nvim/.config/nvim/lua/plugins/`.

### Fish Shell (`fish/`)
- `config.fish` - Environment variables and non-interactive settings
- `conf.d/interactive.fish` - Interactive shell settings (prompt, keybindings)
- `functions/` - 45+ custom fish functions

Note: Interactive settings are in `conf.d/` to work around a Fish 4.0.6 syntax checker bug with piped `source` commands.

Integrations: Starship prompt, fzf, zoxide, eza

### Doom Emacs (`doom/`)
Literate configuration - edit `config.org`, not `config.el`. After changes to `init.el` or `packages.el`, run `doom sync`.

See `doom/.config/doom/CLAUDE.md` for detailed Doom-specific guidance.

### Starship (`starship/`)

Cross-shell prompt configuration in `starship.toml` with custom symbols for 50+ tools/languages.
