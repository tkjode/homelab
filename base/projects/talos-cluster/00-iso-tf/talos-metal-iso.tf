resource "proxmox_virtual_environment_download_file" "talos-metal-iso" {
  content_type  = "iso"
  datastore_id  = "local"
  file_name     = "talos-metal.iso"
  node_name     = ${var.PROXMOX_TARGET}
  url           = "https://talos.com/talos/metal/yoloswag.iso" #FIXME

}