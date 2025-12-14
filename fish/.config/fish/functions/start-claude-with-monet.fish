function start-claude-with-monet
    if test (count $argv) -lt 1
        # No argument: try to grab from macOS clipboard
        if type -q pbpaste
            set PORT (pbpaste | tr -cd '0-9')
        end
        if test -z "$PORT"
            echo "Usage: claude-ide PORT"
            echo "Or copy the Monet port to the clipboard and run without arguments."
            return 1
        end
    else
        set PORT $argv[1]
    end
    
    env ENABLE_IDE_INTEGRATION=t CLAUDE_CODE_SSE_PORT=$PORT claude
end
