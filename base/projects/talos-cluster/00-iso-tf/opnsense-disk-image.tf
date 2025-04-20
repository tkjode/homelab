resource "proxmox_virtual_environment_download_file" "opnsense-disk-image" {
  content_type            = "iso"
  #decompression_algorithm = "gz"
  overwrite_unmanaged     = "true"
  datastore_id            = var.image_datastore
  file_name               = "opnsense-25.1-vga-amd64.img"
  node_name               = var.proxmox_node
  url                     = "https://mirror.ams1.nl.leaseweb.net/opnsense/releases/25.1/OPNsense-25.1-vga-amd64.img.bz2"
}

output "opnsense-disk-image" {
  value = proxmox_virtual_environment_download_file.opnsense-disk-image.id
}