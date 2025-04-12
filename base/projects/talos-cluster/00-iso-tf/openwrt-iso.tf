resource "proxmox_virtual_environment_download_file" "openwrt-image-gz" {
  content_type            = "iso"
  decompression_algorithm = "gz"
  overwrite_unmanaged     = "true"
  datastore_id            = var.image_datastore
  node_name               = var.proxmox_node
  url                     = var.openwrt_release_url
}