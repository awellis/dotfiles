function tide
    set -l session_name (basename (pwd))

    # Create new tmux session with nvim in the first pane
    tmux new-session -d -s $session_name -x (tput cols) -y (tput lines) "nvim"

    # Split right (35%) for Claude Code
    tmux split-window -h -t $session_name -p 35 "fish -c 'claude-ide'"

    # Split the right pane down (30%) for a spare terminal
    tmux split-window -v -t $session_name -p 30

    # Focus the nvim pane
    tmux select-pane -t $session_name:1.1

    # Hide the status bar for this session (toggle with prefix + S)
    tmux set-option -t $session_name status off

    # Attach
    tmux attach-session -t $session_name
end
