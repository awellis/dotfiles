function ltree --wraps=ls --wraps='eza -ls modified' --description 'alias ll eza -ls modified'
    eza --tree --level=2 --icons --git $argv
end
