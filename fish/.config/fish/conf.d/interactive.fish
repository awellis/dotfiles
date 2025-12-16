# Interactive configuration

if not status is-interactive
    return
end

# --- Vi keybindings ---
fish_vi_key_bindings

# Additional vi mode bindings (after fzf to not override)
bind -M insert \cf forward-bigword

# Use eza for directory preview
set -gx fzf_preview_dir_cmd eza --all --color=always

# --- Keybindings ---
# Backspace = delete one character
bind -M insert -k backspace backward-delete-char 2>/dev/null
bind -M insert \x7f backward-delete-char  # DEL fallback

# Ctrl+Backspace = delete previous word
bind -M insert -k sbackspace backward-kill-word 2>/dev/null
bind -M insert \b   backward-kill-word    # ^H
bind -M insert \x17 backward-kill-word    # Ctrl+W sequence

# Alt+Backspace = delete previous word
bind -M insert \e\x7f backward-kill-word  # ESC + DEL
bind -M insert \e\b   backward-kill-word  # ESC + ^H

# Ctrl+Delete = kill word forward
bind -M insert '\e[3;5~' kill-word 2>/dev/null
bind -M insert -k dc kill-word 2>/dev/null

# --- zoxide (smart cd) ---
if type -q zoxide
    zoxide init fish | source
end

# --- starship prompt ---
if type -q starship
    starship init fish | source
end

# --- Aliases and abbreviations ---
# radian R console
function r
    radian $argv
end

# yazi file manager
function y
    yazi $argv
end

# eza list view sorted by modified
abbr -a ll 'eza -l --sort=modified'