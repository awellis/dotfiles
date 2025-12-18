# Ghostty

## OS-Specific Configuration

The main `config` file includes optional OS-specific config files:

```
config-file = ?macos
config-file = ?linux
```

These are split into separate stow packages:

```
ghostty/                     # shared config (stow on all machines)
  .config/ghostty/config

ghostty-macos/               # only stow on macOS
  .config/ghostty/macos      # font-size = 14

ghostty-linux/               # only stow on Linux
  .config/ghostty/linux      # font-size = 12
```

### Usage

On each machine, stow the shared package plus the appropriate OS package:

- **macOS**: `stow ghostty ghostty-macos`
- **Linux**: `stow ghostty ghostty-linux`

The `?` prefix suppresses errors for missing files, so only the stowed OS config gets loaded.
