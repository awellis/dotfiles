function cling
    set -l folders
    for arg in $argv
        if test -d $arg
            set folders $folders $arg
        else if test -f $arg
            set folders $folders (dirname $arg)
        end
    end
    open -a Cling $folders
end

complete -c cling -a '(__fish_complete_directories)'
