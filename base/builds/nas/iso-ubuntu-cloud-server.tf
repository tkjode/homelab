resource "proxmox_virtual_environment_download_file" "ubuntu-cloud-server-iso" {
  content_type        = "iso"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "nas-stonking-server-cloudimg-amd64.img"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/stonking/20260612/stonking-server-cloudimg-amd64.img"
}
