resource "proxmox_virtual_environment_download_file" "ubuntu-cloud-server-iso" {
  content_type        = "iso"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "ubuntu-25.04-server-cloudimg-amd64.img"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/releases/plucky/release/ubuntu-25.04-server-cloudimg-amd64.img"
}


output "talos-metal-iso" {
  value = proxmox_virtual_environment_download_file.talos-metal-iso.id
}