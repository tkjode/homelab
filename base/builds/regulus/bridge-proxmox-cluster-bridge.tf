resource "proxmox_virtual_environment_network_linux_bridge" "proxmox-cluster-bridge" {
  node_name   = var.proxmox_node
  name        = var.cluster-network-bridge
  autostart   = true
  vlan_aware  = false
  comment     = "Regulus Bridge"
}