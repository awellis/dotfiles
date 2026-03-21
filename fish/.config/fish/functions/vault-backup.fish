function vault-backup --description "Git commit vault changes"
    pushd ~/vault
    git add -A
    set -l msg (date +"%Y-%m-%d %H:%M")
    git commit -m "backup: $msg" --quiet 2>/dev/null
    and git push --quiet 2>/dev/null
    and echo "Vault backed up: $msg"
    or echo "Nothing to commit"
    popd
end
