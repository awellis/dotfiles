# dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- [GNU Stow](https://www.gnu.org/software/stow/)
- macOS (tested on Darwin)

## Installation

Clone the repository:

```bash
git clone https://github.com/aellis/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Symlink a package:

```bash
stow -t ~ <package>
```

Symlink all packages:

```bash
stow -t ~ */
```

### Example

To use the fish shell configuration:

```bash
cd ~/dotfiles
stow -t ~ fish
```

This creates a symlink from `~/.config/fish` pointing to `~/dotfiles/fish/.config/fish`, making your fish configuration available system-wide.

## Packages

| Package | Description |
|---------|-------------|
| `doom` | [Doom Emacs](https://github.com/doomemacs/doomemacs) configuration |
| `fish` | [Fish shell](https://fishshell.com/) with Starship, fzf, zoxide, eza |
| `ghostty` | [Ghostty](https://ghostty.org/) terminal emulator |
| `karabiner` | [Karabiner-Elements](https://karabiner-elements.pqrs.org/) keyboard customization |
| `nvim` | [Neovim](https://neovim.io/) with LazyVim |
| `radian` | [radian](https://github.com/randy3k/radian) R console |
| `starship` | [Starship](https://starship.rs/) prompt |
| `yazi` | [Yazi](https://yazi-rs.github.io/) file manager |
| `zed` | [Zed](https://zed.dev/) editor |

## Stow Commands

```bash
# Symlink a package
stow -t ~ <package>

# Remove a symlink
stow -t ~ -D <package>

# Re-stow (after restructuring)
stow -t ~ -R <package>
```

## License

MIT
