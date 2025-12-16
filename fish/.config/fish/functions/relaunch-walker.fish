function relaunch-walker --description 'Restart elephant and walker services'
    systemctl --user restart elephant walker
end
