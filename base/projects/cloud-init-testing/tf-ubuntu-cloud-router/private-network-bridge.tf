resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  node_name   = var.proxmox_node
  name        = "vmbr1"
  comment     = "Private Network Bridge 1"
}