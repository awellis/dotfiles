# Neovim Configuration

LazyVim-based Neovim configuration.

## Structure

```
lua/
├── config/
│   ├── autocmds.lua    # Custom autocommands
│   ├── keymaps.lua     # Custom keybindings
│   ├── lazy.lua        # Lazy.nvim bootstrap
│   └── options.lua     # Neovim options
└── plugins/            # Custom plugin specs
```

## LazyVim Extras

Enabled extras (via `lazyvim.json`):

**AI**: copilot, copilot-chat
**Coding**: blink, mini-surround, neogen, yanky
**Editor**: dial, fzf, leap, mini-files, snacks_explorer, snacks_picker
**Languages**: docker, git, json, lean, markdown, nushell, python, r, tex, toml, typescript, yaml
**Util**: dot, mini-hipatterns

## Notable Custom Plugins

- `claudecode.lua` - Claude Code integration
- `neorg.lua` / `orgmode.lua` - Note-taking
- `R.lua` - R language support
- `vim-slime.lua` - REPL integration
- `colorscheme.lua` - Theme configuration

## Requirements

- Neovim >= 0.9.0
- [LazyVim](https://www.lazyvim.org/)
