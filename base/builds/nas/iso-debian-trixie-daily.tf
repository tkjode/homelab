resource "proxmox_virtual_environment_download_file" "debian-trixie" {
  content_type        = "import"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "debian-trixie.qcow2"
  node_name           = var.proxmox_node
  url                 = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-arm64.qcow2"
}
