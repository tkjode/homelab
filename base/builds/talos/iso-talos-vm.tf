resource "proxmox_download_file" "linux-cloud-init-iso" {
  content_type          = "iso"
  datastore_id          = "local"
  overwrite_unmanaged   = true
  overwrite             = false
  file_name             = "talos-ubuntu-cloud-server-amd64.iso"
  node_name             = var.proxmox_node
  url                   = var.vm_boot_image
}