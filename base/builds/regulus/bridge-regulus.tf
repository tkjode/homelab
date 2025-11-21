resource "proxmox_virtual_environment_network_linux_bridge" "proxmox_cluster_bridge" {
  node_name   = var.proxmox_node
  name        = var.cluster_network_bridge
  autostart   = true
  vlan_aware  = false
  comment     = "Regulus Bridge"
}