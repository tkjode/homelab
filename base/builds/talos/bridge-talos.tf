resource "proxmox_network_linux_bridge" "talos-bridge" {
  node_name   = var.proxmox_node
  name        = local.test_bridge_id
  autostart   = true
  vlan_aware  = false
  comment     = "Talos Kubernetes Cluster Node Network"
}