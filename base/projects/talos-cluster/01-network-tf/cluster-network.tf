resource "proxmox_virtual_environment_network_linux_bridge" "cluster-private-bridge" {
  node_name   = var.proxmox_node
  name        = "vmbr${ var.talos_vlan }"
  comment     = "Talos Cluster Network"
}

output "cluster_bridge_name" {
  value = proxmox_virtual_environment_network_linux_bridge.cluster-private-bridge.name
}

output "cluster_bridge_id" {
  value = proxmox_virtual_environment_network_linux_Bridge.cluster-private-bridge.id
}