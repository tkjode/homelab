resource "proxmox_virtual_environment_pool" "cluster-nodes-pool" {
  pool_id = "${ var.cluster }-k8s"
  comment = "${ var.cluster } resource operations pool"
}


# resource "proxmox_virtual_environment_download_file" "talos-metal-image" {
#   content_type = "iso"
#   datastore_id = var.iso_datastore
#   node_name = var.target_proxmox_node_name
#   url = "https://github.com/siderolabs/talos/releases/download/${ var.talos_version }/metal-amd64.iso"
#   file_name = "talos-metal-amd64-${var.talos_version}.iso"
#   overwrite_unmanaged = true
# }

# resource "proxmox_virtual_environment_download_file" "opnsense-vga-image" {
#   content_type = "iso"
#   datastore_id = var.iso_datastore
#   node_name = var.target_proxmox_node_name
#   url = "https://mirror.wdc1.us.leaseweb.net/opnsense/releases/24.7/OPNsense-24.7-dvd-amd64.iso.bz2"
#   file_name = "OPNSense.vga.iso"
#   decompression_algorithm = "bz2"
#   overwrite_unmanaged = true
# }