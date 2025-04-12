resource "proxmox_virtual_environment_network_linux_vlan" "talos-vlan" {
  node_name   = var.target_proxmox_node_name
  name        = "eno2.${ var.talos_vlan }"
  comment     = "VLAN ${ var.talos_vlan } Cluster Network"
  interface   = "eno2"
  vlan        = var.talos_vlan
}

resource "proxmox_virtual_environment_network_linux_bridge" "cluster-private-bridge" {
  node_name   = var.target_proxmox_node_name
  name        = "vmbr${ var.talos_vlan }"

  depends_on = [
    proxmox_virtual_environment_network_linux_vlan.talos-vlan
  ]
}