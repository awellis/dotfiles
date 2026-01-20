# ~/.config/fish/config.fish  — SINGLE interactive block (avoids stray `end` issues)

# --- Syntax highlighting colors ---
set -g fish_color_autosuggestion 555 brblack
set -g fish_color_cancel -r
set -g fish_color_command --bold
set -g fish_color_comment red
set -g fish_color_cwd green
set -g fish_color_cwd_root red
set -g fish_color_end brmagenta
set -g fish_color_error brred
set -g fish_color_escape bryellow --bold
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_match --background=brblue
set -g fish_color_normal normal
set -g fish_color_operator bryellow
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection brblue
set -g fish_color_search_match bryellow '--background=brblack'
set -g fish_color_selection white --bold '--background=brblack'
set -g fish_color_user brgreen
set -g fish_color_valid_path --underline

# --- macOS tweaks ---
if test (uname) = Darwin
    set -l darwin_version (uname -r | string split .)
end

function __fish_describe_command
    # Empty function to disable command descriptions on macOS
end

# --- Environment variables ---
set -gx EDITOR nvim
set -gx VISUAL nvim
alias vim='nvim'
alias vi='nvim'

set -gx XDG_CONFIG_HOME $HOME/.config

# --- VS Code integration (non-interactive-safe) ---
# if test "$TERM_PROGRAM" = "vscode"
#     source (code --locate-shell-integration-path fish)
# end

# Interactive configuration moved to conf.d/interactive.fish
# to avoid false syntax errors with fish -n

# --- fzf integration (native, by junegunn) ---
if status is-interactive
    if type -q fzf
        fzf --fish | source
    end
end

# --- Conda / Mamba integration (macOS only) ---
if test (uname) = Darwin
    if test -f /opt/homebrew/Caskroom/miniforge/base/bin/conda
        eval (/opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" hook)
    end

    if test -f "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/mamba.fish"
        source "/opt/homebrew/Caskroom/miniforge/base/etc/fish/conf.d/mamba.fish"
    end
end

# --- LM Studio CLI ---
if test (uname) = Darwin
    fish_add_path -g /Users/andrew/.cache/lm-studio/bin
else
    fish_add_path -g /home/andrew/.lmstudio/bin
end
# Added by Antigravity
fish_add_path /Users/andrew/.antigravity/antigravity/bin
