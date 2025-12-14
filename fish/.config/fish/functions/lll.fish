function lll --wraps='eza -ls modified' --wraps='ls -lG' --description 'alias lll ls -lG'
  ls -lG $argv; 
end
