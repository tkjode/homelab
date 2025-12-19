resource "proxmox_virtual_environment_pool" "cluster" {
  comment   = join(" ", [var.cluster_name, "cluster assets"])
  pool_id   = var.cluster_name
}