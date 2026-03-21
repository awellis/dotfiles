function note --description "Quick capture to Obsidian vault"
    set -l vault ~/vault

    switch $argv[1]
        case todo t
            set -l task (string join " " $argv[2..])
            # macOS date uses -v, Linux uses -d
            if test (uname) = Darwin
                set -l due (date -v+3d +"%Y-%m-%d")
            else
                set -l due (date -d "+3 days" +"%Y-%m-%d")
            end
            echo "- [ ] $task 📅 $due" >>$vault/daily/(date +"%Y-%m-%d").md
            echo "Added: $task"

        case idea i
            set -l idea (string join " " $argv[2..])
            echo "- $idea" >>$vault/daily/(date +"%Y-%m-%d").md
            echo "Captured."

        case search s
            rg --type md (string join " " $argv[2..]) $vault

        case '*'
            # No args: open today's daily note
            nvim $vault/daily/(date +"%Y-%m-%d").md
    end
end
