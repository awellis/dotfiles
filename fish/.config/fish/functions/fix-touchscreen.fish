function fix-touchscreen --description "Reload wacom driver to fix touchscreen after suspend/blank"
    if test (uname) != Linux
        echo "This only works on Linux (uses modprobe to reload the wacom kernel module)"
        return 1
    end
    sudo modprobe -r wacom && sudo modprobe wacom
    and echo "Touchscreen driver reloaded"
end
