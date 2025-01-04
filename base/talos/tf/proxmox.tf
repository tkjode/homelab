resource "proxmox_virtual_environment_pool" "talon-k8s" {
  pool_id = "talon-k8s"
  comment = "TALON: Kubernetes with Talos VM"
}

resource "proxmox_virtual_environment_download_file" "talos-metal-image" {
  content_type = "iso"
  datastore_id = var.iso_datastore
  node_name = var.target_proxmox_node_name
  url = "https://github.com/siderolabs/talos/releases/download/v1.9.1/metal-amd64.iso"
}

resource "proxmox_virtual_environment_download_file" "opnsense-vga-image" {
  content_type = "iso"
  datastore_id = var.iso_datastore
  node_name = var.target_proxmox_node_name
  url = "https://mirror.wdc1.us.leaseweb.net/opnsense/releases/24.7/OPNsense-24.7-dvd-amd64.iso.bz2"
}