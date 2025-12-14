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

## Configurations

### Neovim (`nvim/`)
LazyVim-based configuration. Entry point is `lua/` directory with standard LazyVim structure.

### Fish Shell (`fish/`)
- `config.fish` - Environment variables and non-interactive settings
- `conf.d/interactive.fish` - Interactive shell settings (prompt, keybindings)
- `functions/` - Custom fish functions

Integrations: Starship prompt, fzf, zoxide, eza
