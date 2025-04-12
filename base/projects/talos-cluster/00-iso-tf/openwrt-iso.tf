resource "proxmox_virtual_environment_download_file" "openwrt-image-gz" {
  content_type            = "iso"
  #decompression_algorithm = "gz"
  overwrite_unmanaged     = "true"
  datastore_id            = var.image_datastore
  file_name               = "openwrt-${ var.openwrt_release }-x86_64.img"
  node_name               = var.proxmox_node
  url                     = "https://downloads.openwrt.org/releases/${var.openwrt_release}/targets/x86/64/openwrt-${ var.openwrt_release }-x86-64-generic-ext4-combined.img.gz"
}

output "openwrt-disk-image" {
  value = proxmox_virtual_environment_download_file.openwrt-image-gz.id
}