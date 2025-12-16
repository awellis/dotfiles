function pullall --description "Pull origin/main for all git repos in a directory"
    set -l dir (test -n "$argv[1]" && realpath $argv[1] || pwd)

    if not test -d $dir
        echo "Error: $dir is not a directory"
        return 1
    end

    for repo in $dir/*/
        if test -d "$repo/.git"
            set -l name (basename $repo)
            echo -n "$name: "

            set -l output (git -C $repo pull origin main 2>&1)
            set -l status_code $status

            if test $status_code -eq 0
                if string match -q "Already up to date*" $output
                    set_color green
                    echo "up to date"
                else
                    set_color cyan
                    echo "updated"
                end
            else
                set_color red
                echo "failed"
                set_color yellow
                echo $output
            end
            set_color normal
        end
    end
end
