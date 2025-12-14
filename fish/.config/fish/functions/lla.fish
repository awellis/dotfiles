function lla --wraps='eza -ls modified' --wraps='eza -lsa modified' --wraps='eza -la -s modified' --description 'alias lla eza -la -s modified'
    eza -ls modified --icons --git -a $argv
end
