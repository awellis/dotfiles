function tide --description "Start/attach a tmux dev session: nvim + an AI agent pane (claude or pi)"
    # Usage: tide [agent] [session-name]
    #   agent:        claude (default) or pi
    #   session-name: defaults to the current directory name
    set -l agent claude
    set -l session_name (basename (pwd))

    # The first positional arg selects the agent if it names one; otherwise it
    # is treated as the session name (so `tide my-name` still works).
    if set -q argv[1]
        switch $argv[1]
            case claude pi
                set agent $argv[1]
                set -q argv[2]; and set session_name $argv[2]
            case '*'
                set session_name $argv[1]
        end
    end

    # tmux uses ':' and '.' as target separators, so sanitise anything that
    # isn't safe in a session name.
    set session_name (string replace -ar '[^A-Za-z0-9_-]' '_' -- $session_name)

    # If the session already exists, (re)attach instead of erroring out.
    if tmux has-session -t $session_name 2>/dev/null
        if set -q TMUX
            tmux switch-client -t $session_name
        else
            tmux attach-session -t $session_name
        end
        return
    end

    # Command for the agent pane. Both run under `fish -c` so they inherit
    # exported env vars (API keys in conf.d) and fish functions like claude-ide.
    set -l agent_cmd
    switch $agent
        case claude
            # claude-ide waits for nvim's IDE server, then runs `claude --ide`.
            set agent_cmd "fish -c claude-ide"
        case pi
            set agent_cmd "fish -c pi"
    end

    set -l cwd (pwd)

    # nvim in the first (left) pane
    tmux new-session -d -s $session_name -x (tput cols) -y (tput lines) -c $cwd nvim
    # Right column (35%) for the AI agent
    tmux split-window -h -t $session_name -p 35 -c $cwd $agent_cmd
    # Spare shell beneath the agent (30%)
    tmux split-window -v -t $session_name -p 30 -c $cwd
    # Focus the nvim pane
    tmux select-pane -t $session_name:1.1
    # Hide the status bar for this session (toggle with prefix + S)
    tmux set-option -t $session_name status off

    # Attach (or switch, if we are already inside tmux)
    if set -q TMUX
        tmux switch-client -t $session_name
    else
        tmux attach-session -t $session_name
    end
end
