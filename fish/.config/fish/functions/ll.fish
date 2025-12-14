function ll --wraps=ls --wraps='eza -ls modified' --description 'alias ll eza -ls modified'
    eza -ls modified --icons --git $argv
end
