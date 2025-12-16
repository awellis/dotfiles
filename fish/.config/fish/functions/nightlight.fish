function nightlight --description "Set night light temperature"
    echo "Select night light mode:"
    echo "  1) Day (5500K)"
    echo "  2) Evening (4500K)"
    echo "  3) Late night (4000K)"
    echo "  4) Even darker (3600K)"

    read -P "Choice [1-4]: " choice

    switch $choice
        case 1
            gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5500
            echo "Set to day (5500K)"
        case 2
            gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4500
            echo "Set to evening (4500K)"
        case 3
            gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000
            echo "Set to late night (4000K)"
        case 4
            gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3600
            echo "Set to even darker (3600K)"
        case '*'
            echo "Invalid choice"
            return 1
    end
end
