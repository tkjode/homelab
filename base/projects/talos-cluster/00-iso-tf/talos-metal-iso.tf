resource "proxmox_virtual_environment_download_file" "talos-metal-iso" {
  content_type  = "iso"
  datastore_id  = ${var.iso_datastore}
  file_name     = "talos-metal-${var.talos_iso_version}.iso"
  node_name     = ${var.PROXMOX_TARGET}
  url           = "https://github.com/siderolabs/talos/releases/download/${var.talos_iso_version}/metal-amd64.iso"
}