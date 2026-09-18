resource "proxmox_virtual_environment_pool" "cluster" {
  comment   = join(" ", [var.cluster-name, "cluster assets"])
  pool_id   = join(".", [var.cluster-name, var.cluster-domain])
}