### REMOTE DATA >>>>>>>>>>>>>>>>>>>

data "terraform_remote_state" "iso" {
  backend = "s3"
  config = {
    bucket  = "phalnet-homelab-automation"
    key     = "talos/iso"
    region  = "ca-central-1"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket    = "phalnet-homelab-automation"
    key       = "talos/network"
    region    = "ca-central-1"
  }
}

data "terraform_remote_state" "pool" {
  backend = "s3"
  config = {
    bucket    = "phalnet-homelab-automation"
    key       = "talos/pool"
    region    = "ca-central-1"
  }
}

### VARIABLES >>>>>>>>>>>>>>>>>>>

variable "proxmox_node" {
  type = string
}

### RESOURCES >>>>>>>>>>>>>>>>>>>

resource "proxmox_virtual_environment_vm" "gateway" {
  name          = "gateway-opnsense"
  description   = "OPNSense Network Gateway"
  tags          = ["talos", "opnsense"]

  #bios          = "ovmf"
  node_name     = var.proxmox_node
  #machine       = "q35"
  boot_order    = [ "virtio0", "ide3", "net0" ]

  cpu {
    cores   = 4
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated   = 16384
    floating    = 16384
  }

  cdrom {
    file_id     = data.terraform_remote_state.iso.outputs.opnsense-disk-image
    interface   = "ide3"
  }

  disk  {
    datastore_id  = "SSD"
    #file_id       = data.terraform_remote_state.iso.outputs.opnsense-disk-image
    interface     = "virtio0"
    size          = 120
  }

  #efi_disk {
  #  datastore_id  = "SSD"
  #}

  operating_system {
    type    = "l26"
  }

  network_device {
      bridge  = data.terraform_remote_state.network.outputs.cluster_bridge_name
  }

}
