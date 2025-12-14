function get-chainlit-logs
    rsync -e "ssh -i $HOME/.ssh/id_ed25519_exoscale.pub" -a ubuntu@89.145.165.65:/var/log/chainlit/. ~/chainlitlogs
end