function tv_zoxide --description "Fuzzy-jump to a zoxide directory via television"
    type -q tv; or return 1
    type -q zoxide; or return 1

    set -l dir (tv zoxide)
    or return 0
    test -n "$dir"; or return 0

    cd -- $dir
    commandline -f repaint
end
