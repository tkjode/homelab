worker_count              = 6
cluster                   = "talon"
iso_datastore             = "local"
target_proxmox_node_name  = "proxmox"
# talos_version="v1.9.1"
vlan_number               = 100

nodesizing = {
  master = {
    vcpu = 4
    mem  = 8192
  }
  worker = {
    vcpu = 4
    mem  = 8192
  }
}
