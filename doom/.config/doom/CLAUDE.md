# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Doom Emacs configuration repository. Doom Emacs is a configuration framework for Emacs that provides a modern, evil-mode-based experience with extensive language support and powerful modules.

**Key Configuration Files:**
- `init.el` - Doom module configuration and feature flags
- `config.org` - Literate configuration (tangled to `config.el`)
- `config.el` - Generated Emacs Lisp configuration
- `packages.el` - Package declarations and custom packages
- `custom.el` - Emacs custom variables (auto-generated)

## Essential Commands

### Doom Management
```bash
# Synchronize configuration after changes
doom sync

# Update packages
doom sync -u

# Rebuild packages unconditionally  
doom sync -b

# Get detailed system information
doom info

# Clean up orphaned packages
doom gc

# Launch Emacs with this configuration
doom emacs
```

### Development Workflow

1. Edit `config.org` for configuration changes (uses literate programming)
2. Edit `init.el` to enable/disable Doom modules
3. Edit `packages.el` to add/remove packages
4. Run `doom sync` after any changes to packages or modules
5. Restart Emacs to apply configuration changes

## Architecture and Structure

### Configuration Architecture
- **Literate Configuration**: Main configuration lives in `config.org` and is tangled to `config.el`
- **Modular Design**: Uses Doom's module system defined in `init.el`
- **Custom Packages**: Additional packages defined in `packages.el` with straight.el recipes

### Key Components

**Language Support:**
- R and ESS with custom executable paths
- Python with Miniforge integration  
- Julia with tree-sitter support
- JavaScript/TypeScript with tree-sitter
- Org-mode with R, Python, and Julia babel support
- LaTeX, Markdown, YAML, and various other languages

**Development Tools:**
- LSP integration for multiple languages
- Magit for Git operations
- Tree-sitter for enhanced syntax highlighting
- Evil mode (Vim bindings) with extensive configuration
- Company/Corfu for completion
- Vertico for selection/completion interface

**Custom Integrations:**
- Claude Code IDE integration for AI-powered development
- Indent-bars for visual indentation guides
- Aider integration for AI code editing
- Quarto support for scientific publishing

### Module Configuration
The `init.el` file uses Doom's declarative module system:
- `:completion` - Completion frameworks (company, corfu, vertico)
- `:ui` - User interface modules (themes, modeline, etc.)  
- `:editor` - Editor enhancements (evil, snippets, formatting)
- `:tools` - Development tools (LSP, magit, make)
- `:lang` - Language-specific configurations
- `:config` - Configuration framework (literate, defaults)

### Package Management
- Uses straight.el for package management
- Custom packages defined with GitHub recipes
- Transient explicitly included for compatibility
- Packages sync'd with `doom sync` command

### Session and Process Management
- R sessions configured with persistent connections
- Python environment pointing to Miniforge
- Julia with interactive session support
- Org-babel configured for multi-language notebooks

## Font and Theme Configuration
- **Theme**: Tokyo Night (modern dark theme with neon colors)
- **Font**: Fira Code at 16pt with extensive ligature support
- **Ligatures**: Configured for R, Julia, Python, and general programming
- Custom ligature patterns for statistical operators and programming symbols

## Directory Structure
```
~/.config/doom/           # This configuration directory
├── config.org           # Main literate configuration
├── config.el            # Generated configuration
├── init.el              # Doom modules and flags  
├── packages.el          # Package declarations
├── custom.el            # Emacs custom variables
└── snippets/            # Custom snippets (currently empty)

~/.config/emacs/         # Doom Emacs installation
├── bin/doom             # Doom CLI tool
├── modules/             # Doom modules
└── profiles/            # Profile configurations
```

## Important Notes
- Always run `doom sync` after modifying `init.el` or `packages.el`
- Configuration uses literate programming - edit `config.org` not `config.el`
- Custom executable paths are defined for R, Python, and Julia
- Evil mode is enabled globally with extensive keybinding customizations
- Org-directory is set to use iCloud sync via Beorg app
