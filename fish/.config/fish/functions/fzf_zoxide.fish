function fzf_zoxide --description "Fuzzy-jump to a zoxide directory via fzf"
    type -q fzf; or return 1
    type -q zoxide; or return 1

    set -l dir (zoxide query -ls \
        | fzf --no-sort --height=40% --reverse \
              --nth=2.. \
              --preview 'eza --all --color=always --icons {2..}' \
              --preview-window=right:50% \
        | string replace -r '^\s*\d+\s+' '')
    or return 0
    test -n "$dir"; or return 0

    cd -- $dir
    commandline -f repaint
end
