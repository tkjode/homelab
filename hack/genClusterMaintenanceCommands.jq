def ssh(ip; cmd): "ssh -q -o \"UserKnownHostsFile=/dev/null\" -o \"StrictHostKeyChecking=no\" -J gateway " + ip + " " + cmd;

.items 
| map(
    { 
        "hostname": .status.addresses|map(select(.type=="Hostname")) | .[0].address, 
        "ip": .status.addresses|map(select(.type=="InternalIP")) | .[0].address 
    }) 
| map(
        "echo 10 seconds to maintenance on " + .hostname, 
        "sleep 10", 
        "ssh bastion kubectl cordon " + .hostname, 
        "ssh bastion kubectl drain --delete-emptydir-data --ignore-daemonsets " + .hostname,
        "echo Running updates on node " + .hostname, 
        ssh(.ip; "sudo apt update"),
        ssh(.ip; "sudo apt -y dist-upgrade"),
        ssh(.ip; "sudo reboot now"), 
        "sleep 30", 
        "until " + ssh(.ip; "uptime") + "; do printf \".\"; sleep 5; done", 
        "ssh bastion kubectl uncordon " + .hostname
        ) 
| .[]
