function ide
    set -l session_name (basename (pwd))
    zellij --session $session_name --layout ide $argv
end
