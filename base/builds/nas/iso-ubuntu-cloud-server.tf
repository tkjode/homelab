resource "proxmox_virtual_environment_download_file" "ubuntu-cloud-server-iso" {
  content_type        = "iso"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "nas-ubuntu-25.10-server-cloudimg-amd64.img"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/releases/questing/release/ubuntu-25.10-server-cloudimg-amd64.img"
}
