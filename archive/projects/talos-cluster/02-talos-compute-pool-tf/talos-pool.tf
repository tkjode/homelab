resource "proxmox_virtual_environment_pool" "talos_pool" {
  comment = "Managed by Terraform"
  pool_id = "talos-cluster"
}

output "talos-pool-id" {
  value = proxmox_virtual_environment_pool.talos_pool.pool_id
}