# Custom keybindings

if not status is-interactive
    return
end

# tv (television) fuzzy finder
if functions -q tv_shell_history
    for mode in default insert
        bind --mode $mode ctrl-r tv_shell_history
        bind --mode $mode ctrl-t tv_smart_autocomplete
    end
end

# tv + zoxide: fuzzy-jump between frecency-ranked directories
if functions -q tv_zoxide
    for mode in default insert
        bind --mode $mode ctrl-g tv_zoxide
    end
end

# fzf + zoxide: alternative fuzzy-jump (for comparison with tv_zoxide)
if functions -q fzf_zoxide
    for mode in default insert
        bind --mode $mode ctrl-o fzf_zoxide
    end
end

# bang-bang: !! repeats last command, !$ inserts last argument
function __bang_bang_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __bang_bang_previous_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

bind --mode insert ! __bang_bang_previous_command
bind --mode insert '$' __bang_bang_previous_arguments
