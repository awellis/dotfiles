# Fish Shell Configuration

This directory contains my Fish shell configuration files.

## Structure

- `config.fish` - Main configuration file with environment variables and non-interactive settings
- `conf.d/interactive.fish` - Interactive shell settings (prompt, keybindings, etc.)

## Why Split Configuration?

The interactive settings are in a separate file (`conf.d/interactive.fish`) to work around a known bug in Fish 4.0.6 where the syntax checker (`fish -n`) incorrectly reports "Missing end" errors when using command substitution with pipes to `source` (e.g., `starship init fish | source`).

This is a false positive - the syntax is actually correct, but the error prevents the config from loading properly, breaking the prompt and other features.

## Features

### Vi Mode
- Vi keybindings are enabled for command line editing
- Use `Esc` to enter normal mode, `i` to enter insert mode
- Custom binding: `Ctrl+F` in insert mode moves forward by word

### Custom Keybindings (Insert Mode)
- **Backspace** - Delete character backward
- **Ctrl+Backspace** - Delete word backward
- **Alt+Backspace** - Delete word backward
- **Ctrl+Delete** - Delete word forward

### Integrations
- **Starship** - Cross-shell prompt
- **fzf** - Fuzzy finder integration
- **zoxide** - Smarter `cd` command
- **eza** - Modern `ls` replacement (used for fzf directory previews)

### Environment
- Default editor: `nvim`
- Conda/Mamba support (if installed via Miniforge)
- LM Studio CLI path configuration

## Troubleshooting

If you see errors about "Missing end to balance this if statement", this is the known Fish 4.0.6 bug mentioned above. The configuration is working correctly despite the error message.

To verify everything is working:
```fish
# Check if starship is loaded
type -q starship && echo "✓ Starship loaded"

# Check if vi mode is active
echo $fish_key_bindings  # Should show "fish_vi_key_bindings"

# Check if fzf is integrated
type -q __fzf_search_history && echo "✓ fzf integrated"
```