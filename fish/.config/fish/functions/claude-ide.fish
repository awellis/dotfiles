function claude-ide
    # Give neovim time to start and register its IDE server (claudecode.nvim)
    sleep 2
    claude --ide $argv
end
