resource "proxmox_download_file" "ubuntu-cloud-server-iso" {
  content_type        = "iso"
  datastore_id        = var.iso_datastore
  overwrite_unmanaged = true
  file_name           = "gamededi-resolute-server-cloudimg-amd64.img"
  node_name           = var.proxmox_node
  url                 = "https://cloud-images.ubuntu.com/resolute/20260421/resolute-server-cloudimg-amd64.img"
}
