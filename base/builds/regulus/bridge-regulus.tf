resource "proxmox_virtual_environment_network_linux_bridge" "vmbr10" {
  node_name   = var.proxmox_node
  name        = "vmbr10"
  autostart   = true
  vlan_aware  = false
  comment     = "Regulus Bridge"
}