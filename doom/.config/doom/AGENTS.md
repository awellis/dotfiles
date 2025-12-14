# AGENTS.md - AI Agent Guidelines for Doom Emacs Configuration

## Build/Lint/Test Commands
- **Synchronize configuration**: `doom sync` (required after changes to init.el, packages.el)
- **Update packages**: `doom sync -u`
- **Rebuild packages**: `doom sync -b`
- **Clean orphans**: `doom gc`
- **System info**: `doom info`
- **Launch Emacs**: `doom emacs`

## Code Style Guidelines

### Configuration Structure
- **Main config**: Edit `config.org` (literate programming), NOT `config.el` (auto-generated)
- **Module config**: `init.el` uses Doom's declarative module system
- **Package declarations**: `packages.el` with straight.el recipes
- **Always run `doom sync` after package/module changes**

### Emacs Lisp Conventions
- Use `after!` macro for package configuration
- Use `use-package!` for external packages
- Use `map!` macro for keybindings
- Prefer lexical binding: `;;; -*- lexical-binding: t; -*-`
- Group related configurations with clear headers
- Use `setq` for simple variable assignments
- Define custom variables with `defvar` before use
- Comment sections clearly for organization

### Error Handling
- Check package availability with `(require 'package nil t)`
- Use `(featurep :system 'macos)` for system-specific code
- Wrap configurations in `after!` or `with-eval-after-load`