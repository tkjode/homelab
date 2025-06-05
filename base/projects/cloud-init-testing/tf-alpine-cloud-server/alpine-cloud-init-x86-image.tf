resource "proxmox_virtual_environment_download_file" "alpine-qcow2-image" {
  content_type        = "iso"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "generic-alpine-x86_64-bios-cloudinit.img"
  node_name           = var.proxmox_node
  url                 = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.0-x86_64-bios-cloudinit-r0.qcow2"
}
