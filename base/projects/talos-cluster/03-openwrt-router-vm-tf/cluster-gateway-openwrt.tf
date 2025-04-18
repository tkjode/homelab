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
  name      = "gateway-openwrt"
  description = "OpenWRT router gateway through bridge networks and DHCP Provider"
  tags        = ["talos", "openwrt"]

  node_name   = var.proxmox_node

  cpu {
    cores   = 2
    type    = "x86-64-v2-AES"
  }

  memory {
    dedicated   = 2048
    floating    = 2048
  }

  disk  {
    datastore_id  = "SSD"
    file_id       = data.terraform_remote_state.iso.outputs.openwrt-disk-image
    interface     = "virtio0"
  }

  network_device {
      bridge  = data.terraform_remote_state.network.outputs.cluster_bridge_id
  }

}

